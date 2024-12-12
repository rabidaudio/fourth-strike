# frozen_string_literal: true

# Handles importing of the Bandcamp raw data report
# rubocop:disable Rails/Output,Metrics/BlockLength,Rails/SkipsModelValidations
class BandcampReport
  def self.load_report!(path) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
    CalculatorCache::Manager.defer_recompute do
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

          if row['net amount']
            # (41.11+3.89+2.77+5) sub+additional+tax+ship = 52.77 item total
            # - 1.46 transaction fee
            # - 4.50 rev share
            # - 5 shipping
            # = 39.04 net amount
            net = row['net amount'].to_money(row['currency'])
          else
            # net amount is not defined for some transactions, probably when revenues were
            # so low that Bandcamp wasn't taking a cut.
            # None of these have tax collected, so we only need to remove transction fee and
            # shipping from these
            transaction_fee = row['transaction fee'].to_money(row['currency'])
            shipping = row['shipping'].to_money(row['currency'])
            net = subtotal - transaction_fee - shipping
          end

          # Convert other currencies to USD
          if Rails.application.config.app_config[:bandcamp][:currency_corrections].key?(bandcamp_transaction_id)
            conversion = Rails.application.config.app_config[:bandcamp][:currency_corrections][bandcamp_transaction_id]
            subtotal = (subtotal.amount / conversion).to_money('USD')
            net = (net.amount / conversion).to_money('USD')
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
                                }, unique_by: [:bandcamp_transaction_id, :item_url])

          when 'package'
            # This step only creates merch items and bandcamp sales. Fulfillments will need to be
            # created by hand :/

            # additional fan contribution does happen
            # paypal transaction id can include "<-- collected to cover your revenue share balance"
            # balances can include "n/a" instead of blank/zero
            # skus don't line up exactly with master doc
            # tax sometimes collected

            sku = row['sku']
            if Rails.application.config.app_config[:bandcamp][:merch_sku_remaps].key?(sku)
              sku = Rails.application.config.app_config[:bandcamp][:merch_sku_remaps][sku]
            end

            merch = Merch.where(bandcamp_url: row['item url'])

            merch = Merch.where(bandcamp_url: row['item url'], sku: sku) if merch.count > 1

            merch = merch.first
            if merch.nil?
              if row['item url'].in?(Rails.application.config.app_config[:bandcamp][:skip_merch])
                puts("skipping #{row['item url']}")
                next
              end

              raise StandardError, "Merch not found: #{row['sku']} - #{row['item name']}"
            end

            unless row['paypal transaction id']&.starts_with?('<-- collected to cover your revenue share balance')
              paypal_transaction_id = row['paypal transaction id'] # :eyeroll:
            end

            BandcampSale.upsert({
                                  item_url: row['item url'],
                                  product_id: merch.id,
                                  product_type: 'Merch',
                                  sku: row['sku'],
                                  option: row['option'],
                                  subtotal_amount_cents: subtotal.cents,
                                  subtotal_amount_currency: subtotal.currency.iso_code,
                                  net_revenue_amount_cents: net.cents,
                                  net_revenue_amount_currency: net.currency.iso_code,
                                  bandcamp_transaction_id: bandcamp_transaction_id,
                                  paypal_transaction_id: paypal_transaction_id,
                                  quantity: row['quantity'],
                                  purchased_at: purchased_at,
                                  shipping_destination: [row['city'], row['region/state'],
                                                         row['country code']].compact.join(', '),
                                  notes: notes
                                }, unique_by: [:bandcamp_transaction_id, :item_url])

          when 'bundle'
            # Bundles are sales of the entire discography
            # For discography purchases, what we do is take the entire discography released up to that point,
            # divide the money proportionally based on the sale value of the albums, then create a sale for
            # each album for that weighted amount
            albums = Album.where('bandcamp_url like ?', "#{row['item url']}%").where(release_date: ..purchased_at)
            total_value = albums.sum_monetized(:bandcamp_price)
            weighted_values = albums.index_with { |a| a.bandcamp_price / total_value }

            albums.each do |album|
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
                                    bandcamp_transaction_id: bandcamp_transaction_id,
                                    paypal_transaction_id: row['paypal transaction id'],
                                    quantity: row['quantity'],
                                    purchased_at: purchased_at,
                                    notes: notes
                                  }, unique_by: [:bandcamp_transaction_id, :item_url])
            end

          when 'payout' then next
          when 'pending reversal', 'cancelled reversal', 'reversal', 'refund'
            # if a sale exists for this, refund it
            # NOTE: any expenses related to refunds/chargebacks are implicitly eaten by the org
            BandcampSale.where(bandcamp_transaction_id: bandcamp_transaction_id).update_all(refunded: true)
          else raise StandardError, "Unknown item type: #{row['item type']}"
          end
        end
      end
    end
  end
end
# rubocop:enable Rails/Output,Metrics/BlockLength,Rails/SkipsModelValidations
