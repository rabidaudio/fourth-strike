# frozen_string_literal: true

namespace :distrokid do
  desc 'Loads Distrokid sale data from their raw data report'
  task :load_report => :environment do
    require 'csv'

    path = Rails.root.glob('exports/DistroKid_*.tsv').first
    raise StandardError, 'Report not found' if path.nil?

    DistrokidReport.upsert_all!(path)
  end

  desc 'Crawl distrokid website and export a report of all UPC/ISRCs. This likely only needs to be done once.'
  task :export_isrcs => :environment do
    require 'ferrum'
    require 'csv'
    require 'tty-prompt'

    browser = Ferrum::Browser.new
    prompt = TTY::Prompt.new

    page = browser.create_page

    # Doesn't work, Captcha :/
    # page.go_to('https://distrokid.com/signin/')
    # email = prompt.ask("email", default: "info@fourth-strike.com")
    # password = prompt.mask("password")
    # page.at_css('input#inputEmail').type(email)
    # page.at_css('input#inputPassword').type(password)
    # page.at_css('#signInButtonStandalonePage').click
    # page.network.wait_for_idle!

    # Instead, grab cookies. Less than ideal but shouldn't need to be done often
    cookies = prompt.ask('Log into DistroKid in your browser. ' \
                         'Then open a console and get cookies with `document.cookie`. Paste the result here: ')
    cookies.split('; ').each do |cookie|
      name, value = cookie.split('=', 2)
      page.cookies.set(name: name, value: value, domain: 'distrokid.com')
    end

    page.go_to('https://distrokid.com/mymusic/')

    CSV.open(Rails.root.join('exports/isrcs.csv'), 'w', force_quotes: true) do |csv|
      # headers
      csv << [
        'album_name',
        'artist_name',
        'album_uuid',
        'album_upc',
        'release_date',
        'upload_date',
        'track_number',
        'track_name',
        'track_isrc'
      ]

      album_links = page.css('section.releases-list a.tableRow').map do |album_row|
        href = album_row.attribute('href')
        href = "https://distrokid.com#{href}" unless href.starts_with?('http')
        href
      end

      album_links.each do |album_link|
        puts(album_link)
        page.go_to(album_link)

        album_uuid = Rack::Utils.parse_nested_query(URI(album_link).query)['albumuuid']

        album_name = page.at_css('.albumTitleBig').text.strip
        artist_name = page.at_css('.bandNameBig').text.strip
        album_upc = page.at_css('#js-album-upc').text.strip

        release_info = page.at_css('.UPC').text.lines.map(&:strip)
        release_date = release_info.find { |l| l.start_with?('Release date: ') }.delete_prefix('Release date: ')
        upload_date = release_info.find { |l| l.start_with?('Uploaded: ') }.delete_prefix('Uploaded: ')

        page.css('tr[id^=tracknum]').each do |song_row|
          track_isrc = song_row.at_css('.myISRC').text.gsub('ISRC', '').strip
          track_name = song_row.at_css('span[title]').text.strip
          track_number = song_row.attribute('id').delete_prefix('tracknum').to_i

          csv << [
            album_name, artist_name, album_uuid, album_upc, release_date, upload_date,
            track_number, track_name, track_isrc
          ]
        end
      end
    end
  end

  desc 'Load the report mapping ISRCs to bandcamp urls and update album/track information'
  task :import_isrcs => :environment do
    require 'csv'

    csv = CSV.read(Rails.root.join('exports/ISRCs to Bandcamp URLs.csv'), headers: true)
    rows = csv.each.to_a

    ActiveRecord::Base.transaction do
      # 1. Update all Album UPCs
      album_upcs = rows.select { |r| r['bandcamp_album_url'].present? }
                       .map { |r| [r['bandcamp_album_url'], r['album_upc']] }
                       .uniq.group_by(&:first).transform_values { |v| v.map(&:last) }

      album_upcs.each do |bandcamp_url, upcs|
        Album.find_by!(bandcamp_url: bandcamp_url).update!(upcs: upcs)
      end

      # 2. Update all track ISRCs
      rows.each do |row|
        next if row['bandcamp_track_url'].blank?

        track = Track.find_by!(bandcamp_url: row['bandcamp_track_url'])
        if track.isrc.present? && track.isrc != row['track_isrc']
          raise StandardError, "Multiple ISRCs for #{row['bandcamp_track_url']}"
        end

        track.update!(isrc: row['track_isrc'])
      end

      # 3. Create hidden tracks for any missing from Bandcamp
      rows.each do |row| # rubocop:disable Style/CombinableLoops
        next if row['bandcamp_track_url'].present?

        puts("Creating hidden track #{row['track_name']} from #{row['album_name']}: #{row['track_isrc']}")
        Track.create_with(
          bandcamp_url: row['bandcamp_track_url'],
          isrc: row['track_isrc'],
          name: row['track_name'],
          track_number: nil,
          album: Album.find_by!(bandcamp_url: row['bandcamp_album_url'])
        ).find_or_create_by!(isrc: row['track_isrc'])
      end
    end
  end
end
