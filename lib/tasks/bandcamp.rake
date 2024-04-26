# frozen_string_literal: true

namespace :bandcamp do
  # NOTE: this relies heavily on the structure of the bandcamp website.
  # It's liable to break eventually when bandcamp redesigns their site.
  # However, fixing it should just be a matter of updating CSS accessors.
  # Unfortunately Bandcamp doesn't have a public API and their private one
  # doesn't include release data.
  # rubocop:disable Rails/SkipsModelValidations
  desc 'Crawls bandcamp.com for all releases and upserts them'
  task :load_releases => :environment do
    require 'ferrum'

    browser = Ferrum::Browser.new
    bandcamp_url = Rails.application.config.app_config[:bandcamp][:url]

    ActiveRecord::Base.transaction do
      page = browser.create_page
      page.go_to("https://#{bandcamp_url}/music")
      # scroll to bottom of page by looking for footer element
      page.at_css('#pgFt').scroll_into_view

      album_links = page.css('li[data-item-id] a').map do |el|
        href = el.attribute('href')
        href = "https://#{bandcamp_url}#{href}" unless href.starts_with?('http')
        href = URI(href).tap { |u| u.query = '' }.to_s.delete_suffix('?')
        href
      end

      album_count = 0
      track_count = 0

      album_links.each do |album_link|
        if Rails.application.config.app_config[:bandcamp][:skip_releases].include?(album_link)
          puts("Skipping #{album_link}")
          next
        end

        attempts = 0
        loop do
          page.go_to(album_link)
          puts(album_link)

          # Seems like Bandcamp throttle shows up as an empty page
          break unless page.at_css('body').text.empty?

          puts('page blank. retrying....')
          attempts += 1
          sleep([30, (2**attempts)].max.seconds)
        end

        album_name = page.at_css('#name-section .trackTitle').text.strip
        artist_name = page.at_css('#name-section span').text.strip

        release_date = Time.zone.parse(page.at_css('.tralbum-credits').text.strip
          .lines.first.strip.delete_prefix('released '))
        album_art_url = page.at_css('#tralbumArt img')&.attribute('src')

        res = Album.upsert({
                             name: album_name,
                             artist_name: artist_name,
                             release_date: release_date,
                             album_art_url: album_art_url,
                             bandcamp_url: album_link
                           }, unique_by: :bandcamp_url)
        album_id = res.rows[0][0]
        album_count += 1

        # we need to load all the track data here before navigating to any other pages
        track_data = page.css('#track_table tr[rel]').map do |el|
          {
            track_number: el.at_css('.track-number-col').text.to_i,
            name: el.at_css('.title').text.strip.lines[0].strip,
            bandcamp_url: URI(album_link).tap { |u| u.path = el.at_css('.title a').attribute('href') }.to_s,
            album_id: album_id
          }
        end

        track_data.each do |track|
          attempts = 0
          loop do
            page.go_to(track[:bandcamp_url])
            puts(track[:bandcamp_url])

            break unless page.at_css('body').text.empty?

            puts('page blank. retrying....')
            attempts += 1
            sleep([30, (2**attempts)].max.seconds)
          end

          credits = nil
          if page.at_css('.tralbum-credits')
            credits = page.at_css('.tralbum-credits').text.strip
                          .lines&.map(&:strip)&.compact_blank&.[](2..)&.join("\n")
                          &.delete_prefix(track[:name])&.strip
          end
          credits = page.at_css('.tralbum-about').text.strip if credits.blank? && page.at_css('.tralbum-about')

          Track.upsert({
                         **track,
                         lyrics: page.at_css('.lyricsText')&.text&.strip,
                         credits: credits
                       }, unique_by: :bandcamp_url)
          track_count += 1
        end
      end

      browser.quit

      puts("Fetched #{album_count} albums and #{track_count} tracks")
    end
  end
  # rubocop:enable Rails/SkipsModelValidations
end
