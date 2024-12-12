# frozen_string_literal: true

# rubocop:disable Rails/SkipsModelValidations
namespace :bandcamp do
  # NOTE: this relies heavily on the structure of the bandcamp website.
  # It's liable to break eventually when bandcamp redesigns their site.
  # However, fixing it should just be a matter of updating CSS accessors.
  # Unfortunately Bandcamp doesn't have a public API and their private one
  # doesn't include release data.
  desc 'Crawls bandcamp.com for all releases and upserts them'
  task :load_releases => :environment do
    require 'ferrum'

    browser = Ferrum::Browser.new(Rails.application.config.ferrum_browser)
    bandcamp_url = Rails.application.config.app_config[:bandcamp][:url]
    fetch_credits = ENV.fetch('fetch_credits', 'false').to_b

    ActiveRecord::Base.transaction do
      page = browser.create_page
      page.go_to("https://#{bandcamp_url}/music")
      # scroll to bottom of page by looking for footer element
      page.at_css('page-footer').scroll_into_view

      album_links = page.css('li[data-item-id] a').map do |el|
        href = el.attribute('href')
        href = "https://#{bandcamp_url}#{href}" unless href.starts_with?('http')
        href = URI(href).tap { |u| u.query = '' }.to_s.delete_suffix('?')
        href
      end

      album_links += Rails.application.config.app_config[:bandcamp][:additional_albums]

      album_count = 0
      track_count = 0

      album_links.each do |album_link|
        next if album_link.include?('bandcamp.com/track/') # skip individual tracks

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

        album_data = JSON.parse(page.at_css('script[type="application/ld+json"]').text)
        release_data = album_data['albumRelease'].find { |r| r['@id'] == album_link }

        album_name = album_data['name']
        bandcamp_id = release_data&.dig('additionalProperty')&.find { |p| p['name'] == 'item_id' }&.dig('value')&.to_s
        artist_name = album_data.dig('byArtist', 'name')
        album_art_url = album_data['image']
        release_date = Date.parse(album_data['datePublished'])
        price = release_data['offers']['price'].to_money(release_data['offers']['priceCurrency'])
        release_data['identifier']

        res = Album.upsert({
                             name: album_name,
                             private: false,
                             artist_name: artist_name,
                             release_date: release_date,
                             album_art_url: album_art_url,
                             bandcamp_price_cents: price.cents,
                             bandcamp_price_currency: price.currency.iso_code,
                             bandcamp_id: bandcamp_id,
                             bandcamp_url: album_link
                           }, unique_by: :bandcamp_url)
        album_id = res.rows[0][0]
        album_count += 1

        tracks = album_data.dig('track', 'itemListElement').map do |track|
          {
            track_number: track['position'],
            name: track.dig('item', 'name'),
            bandcamp_url: track.dig('item', '@id'),
            lyrics: track.dig('item', 'recordingOf', 'lyrics', 'text'),
            album_id: album_id
          }
        end

        tracks.each do |track|
          if fetch_credits
            attempts = 0
            loop do
              page.go_to(track[:bandcamp_url])
              puts(track[:bandcamp_url])

              break unless page.at_css('body').text.empty?

              puts('page blank. retrying....')
              attempts += 1
              sleep([30, (2**attempts)].max.seconds)
            end

            track_data = JSON.parse(page.at_css('script[type="application/ld+json"]').text)

            track[:credits] = track_data['creditText'] || track_data['description']
            track[:bandcamp_id] = track_data['additionalProperty']&.find do |p|
                                    p['name'] == 'track_id'
                                  end&.dig('value')&.to_s
          end

          Track.upsert(track, unique_by: :bandcamp_url)
          track_count += 1
        end
      end

      Rails.application.config.app_config[:bandcamp][:single_track_albums].each do |track_url|
        attempts = 0
        loop do
          page.go_to(track_url)
          puts(track_url)

          break unless page.at_css('body').text.empty?

          puts('page blank. retrying....')
          attempts += 1
          sleep([30, (2**attempts)].max.seconds)
        end

        track_data = JSON.parse(page.at_css('script[type="application/ld+json"]').text)

        res = Album.upsert({
                             name: track_data['name'],
                             private: false,
                             artist_name: track_data['byArtist']['name'],
                             release_date: Date.parse(track_data['datePublished']),
                             album_art_url: track_data['image'],
                             bandcamp_id: nil,
                             bandcamp_url: track_url
                           }, unique_by: :bandcamp_url)
        album_id = res.rows[0][0]
        Track.upsert({
                       name: track_data['name'],
                       album_id: album_id,
                       track_number: 1,
                       lyrics: track_data['recordingOf']['lyrics']['text'],
                       credits: track_data['creditText'] || track_data['description'],
                       bandcamp_url: track_url,
                       bandcamp_id: track_data['additionalProperty']&.find do |p|
                                      p['name'] == 'track_id'
                                    end&.dig('value')&.to_s
                     }, unique_by: [:album_id, :track_number])
        album_count += 1
        track_count += 1
      end

      browser.quit

      puts("Fetched #{album_count} albums and #{track_count} tracks")
    end
  end

  desc 'Load albums manually defined which are no longer on Bandcamp'
  task :load_missing_albums => :environment do
    ActiveRecord::Base.transaction do
      Rails.application.config.app_config[:bandcamp][:missing_albums].each do |album_data|
        album = Album.create_with(
          album_data.slice(
            :name, :artist_name, :release_date, :upcs, :bandcamp_id, :private, :bandcamp_url, :album_art_url
          ).merge(bandcamp_price: album_data[:bandcamp_price].to_money)
        ).find_or_create_by!(bandcamp_url: album_data[:bandcamp_url])

        album_data[:tracks].each do |track_data|
          Track.create_with(
            track_data.slice(:name, :track_number, :bandcamp_id, :bandcamp_url, :credits, :lyrics).merge(album: album)
          ).find_or_create_by!(bandcamp_url: track_data[:bandcamp_url])
        end
      end
    end
  end

  desc 'Loads merch items from a hand-crafted report'
  task :load_merch_items => :environment do
    merch_count = 0
    ActiveRecord::Base.transaction do
      # Load from the hand-created report
      CSV.foreach(Rails.root.join('storage/exports/Bandcamp Merch Items - data.csv'), headers: true) do |row|
        # name,url,sku,artist_name,list_price,private,variants

        sku = row['sku']
        if Rails.application.config.app_config[:bandcamp][:merch_sku_remaps].key?(sku)
          sku = Rails.application.config.app_config[:bandcamp][:merch_sku_remaps][sku]
        end

        albums = row['album_names'].split('|').map { |n| Album.find_by!(name: n) } if row['album_names'].present?
        list_price = row['list_price'].to_money('USD')

        # wipe any existing relations
        AlbumMerch.joins(:merch_item).where(merch_items: { bandcamp_url: row['url'], sku: sku }).delete_all

        res = Merch.upsert({
                             bandcamp_url: row['url'],
                             name: row['name'],
                             artist_name: row['artist_name'],
                             sku: sku,
                             variants: JSON.parse(row['variants']).to_json,
                             private: row['private'] == 'TRUE',
                             list_price_cents: list_price.cents,
                             list_price_currency: list_price.currency.iso_code
                           }, unique_by: [:bandcamp_url, :sku])

        merch_id = res.rows[0][0]
        AlbumMerch.create!(albums.map { |a| { album_id: a.id, merch_item_id: merch_id } }) if albums.present?

        merch_count += 1
      end

      # Also load from the Bandcamp sales report
      path = Rails.root.glob('storage/exports/Fourth-Strike-Records_sales_*').first
      CSV.foreach(path, headers: true, liberal_parsing: true, encoding: 'UTF-16LE') do |row|
        next unless row['item type'] == 'package'
        next unless Rails.application.config.app_config[:bandcamp][:load_merch_from_sales].key?(row['item url'])

        data = Rails.application.config.app_config[:bandcamp][:load_merch_from_sales][row['item url']]

        album = Album.find_by!(name: data['album'], artist_name: row['artist']) if data['album'].present?
        AlbumMerch.joins(:merch_item).where(merch_items: { bandcamp_url: row['item url'], sku: data['sku'] }).delete_all
        merch = Merch.create_with(
          bandcamp_url: row['item url'],
          name: row['item name'],
          artist_name: row['artist'],
          sku: data['sku'],
          variants: [],
          private: data['private'],
          list_price: data['list_price'].to_money
        ).find_or_create_by!(bandcamp_url: row['item url'], sku: data['sku'])

        AlbumMerch.create!(album: album, merch_item: merch) if album.present?

        variant = { title: row['option'], sku: row['sku'] }
        unless merch.variants.any? { |v| v['sku'] == variant[:sku] }
          merch.variants = [*merch.variants, variant]
          merch.save!
        end
      end
    end
    puts("Fetched #{merch_count} merch items")
  end

  desc 'Loads Bandcamp sale data from their raw data report'
  task :load_report => :environment do
    path = Rails.root.glob('storage/exports/*_bandcamp_raw_data_*').max
    raise StandardError, 'Report not found' if path.nil?

    BandcampReport.load_report!(path)
  end

  task :load_pledges => :environment do
    path = Rails.root.join('storage/exports/thegarages_pledgers.csv')

    ActiveRecord::Base.transaction do
      # liberal_parsing: true
      rows = CSV.read(path, headers: true).each.to_a

      # we need to evenly weight the true net revenue across all the pledges
      campaign_revenue = Rails.application.config.app_config[:bandcamp][:campaigns][:unstable][:net_revenue].to_money
      total_pledge_amount = rows.pluck('pledge ($)').map(&:to_money).sum
      funded_at = Time.zone.parse(Rails.application.config.app_config[:bandcamp][:campaigns][:unstable][:funded_at])
      product = Merch.find_by!(sku: Rails.application.config.app_config[:bandcamp][:campaigns][:unstable][:product])

      product.update!(external_distributor: :bandcamp_campaign)

      rows.each do |row|
        pledge_amount = row['pledge ($)'].to_money
        net_revenue = pledge_amount * (campaign_revenue / total_pledge_amount)
        BandcampPledge.upsert({
                                level: row['level'],
                                funded_at: funded_at,
                                product_type: 'Merch',
                                product_id: product.id,
                                bandcamp_pledge_id: row['id'],
                                pledge_amount_cents: pledge_amount.cents,
                                pledge_amount_currency: pledge_amount.currency.iso_code,
                                net_revenue_amount_cents: net_revenue.cents,
                                net_revenue_amount_currency: net_revenue.currency.iso_code
                              }, unique_by: [:bandcamp_pledge_id])
      end
    end
    CalculatorCache::Manager.recompute_all!
  end
end
# rubocop:enable Rails/SkipsModelValidations
