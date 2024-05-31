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

    browser = Ferrum::Browser.new
    bandcamp_url = Rails.application.config.app_config[:bandcamp][:url]
    fetch_credits = ENV.fetch('fetch_credits', 'false').to_b

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

      browser.quit

      puts("Fetched #{album_count} albums and #{track_count} tracks")
    end
  end

  desc 'Loads Bandcamp sale data from their raw data report'
  task :load_report => :environment do
    require 'csv'

    path = Rails.root.glob('exports/*_bandcamp_raw_data_Fourth-Strike-Records.csv').first
    raise StandardError, 'Report not found' if path.nil?

    ActiveRecord::Base.transaction do
      CSV.foreach(path, headers: true, liberal_parsing: true, encoding: 'UTF-16LE') do |row|
        bandcamp_transaction_id = row['bandcamp transaction id']

        upc = row['upc'].gsub(' ', '').strip if row['upc'].present?
        subtotal = row['item total'].to_money(row['currency'])

        # grab all the accounting columns but none of the customer PII
        notes = row.to_h.slice(*row.headers[0..36]).to_json

        # annoyingly there's some nasty utf-26 char at the beginning
        # instead we assume that the date is the first column
        date = row[0] # row['date']
        purchased_at = Time.zone.strptime(date, '%m/%d/%y %l:%M %P')

        # For some reason, the first couple of rows do not have computed net amounts.
        # Perhaps before that we were considered a non-profit or too small to be billed
        # by bandcamp? anyway we'll calculate manually
        if row['net amount']
          net = row['net amount'].to_money(row['currency'])
        else
          transaction_fee = row['transaction fee'].to_money(row['currency'])
          net = subtotal - transaction_fee
        end

        case row['item type']
        when 'album', 'track'
          product_class = { 'album' => Album, 'track' => Track }[row['item type']]
          product = product_class.find_by(bandcamp_url: row['item url'])

          if product.nil?
            if row['item url'].in?(Rails.application.config.app_config[:bandcamp][:skip_releases])
              puts("skipping #{row['item url']}")
              next
            end

            if row['item url'].in?(Rails.application.config.app_config[:bandcamp][:remaps].keys)
              remap_url = Rails.application.config.app_config[:bandcamp][:remaps][row['item url']]
              # Sometimes we remap an album sale to a track
              product = Album.find_by(bandcamp_url: remap_url) || Track.find_by(bandcamp_url: remap_url)
            end

            raise StandardError, "No #{row['item type']} found for sale of #{row['item url']}" if product.nil?
          end

          BandcampSale.upsert({
                                item_url: row['item url'],
                                product_id: product.id,
                                product_type: product.class.name,
                                upc: upc,
                                subtotal_amount_cents: subtotal.cents,
                                subtotal_amount_currency: subtotal.currency.iso_code,
                                net_revenue_amount_cents: net.cents,
                                net_revenue_amount_currency: net.currency.iso_code,
                                bandcamp_transaction_id: bandcamp_transaction_id,
                                paypal_transaction_id: row['paypal transaction id'],
                                quantity: row['quantity'],
                                purchased_at: purchased_at,
                                notes: notes
                              }, unique_by: :bandcamp_transaction_id)

        when 'package' then next # TODO: merch : sku
        when 'bundle'
          # Bundles are sales of the entire discography
          # For discography purchases, what we do is take the entire discography released up to that point,
          # divide the money proportionally based on the sale value of the albums, then create a sale for
          # each album for that weighted amount
          albums = Album.where('bandcamp_url like ?', "#{row['item url']}%").where('release_date <= ?', purchased_at)
          total_value = albums.sum_monetized(:bandcamp_price)
          weighted_values = albums.index_with { |a| a.bandcamp_price / total_value }
          albums.each_with_index do |album, i|
            weighted_subtotal = weighted_values[album] * subtotal
            weighted_net = weighted_values[album] * net
            BandcampSale.upsert({
                                  item_url: row['item url'],
                                  product_id: album.id,
                                  product_type: 'Album',
                                  upc: upc,
                                  subtotal_amount_cents: weighted_subtotal.cents,
                                  subtotal_amount_currency: weighted_subtotal.currency.iso_code,
                                  net_revenue_amount_cents: weighted_net.cents,
                                  net_revenue_amount_currency: weighted_net.currency.iso_code,
                                  bandcamp_transaction_id: "#{bandcamp_transaction_id}:#{i}",
                                  paypal_transaction_id: row['paypal transaction id'],
                                  quantity: row['quantity'],
                                  purchased_at: purchased_at,
                                  notes: notes
                                }, unique_by: :bandcamp_transaction_id)
          end

        when 'payout' then next # rubocop:disable Lint/DuplicateBranch
        # TODO: should we account for this?
        when 'pending reversal', 'cancelled reversal', 'refund' then next # rubocop:disable Lint/DuplicateBranch
        else raise StandardError, "Unknown item type: #{row['item type']}"
        end
      end
    end
  end
end
# rubocop:enable Rails/SkipsModelValidations
