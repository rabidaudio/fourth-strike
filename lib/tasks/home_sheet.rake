# frozen_string_literal: true

# rubocop:disable Rails/SkipsModelValidations
namespace :home_sheet do
  desc 'Populate payees and splits from home spreadsheet'
  task :load_splits => :environment do
    HomeSheetReport.new(Rails.root.glob('exports/FOURTH STRIKE HOME SHEET*.xlsx').first).load_all!
  end

  desc 'Load merch items that are not on Bandcamp'
  task :load_merch_items => :environment do
    Rails.application.config.app_config[:home_sheet][:merch].each do |merch_data|
      list_price = merch_data.delete('list_price').to_money
      album_name = merch_data.delete('album')
      variants = merch_data.delete('variants').to_json
      album = Album.find_by!(name: album_name) if album_name.present?

      Merch.upsert(merch_data.merge({ # rubocop:disable Rails/SkipsModelValidations
                                      album_id: album&.id,
                                      variants: variants,
                                      list_price_cents: list_price.cents,
                                      list_price_currency: list_price.currency.iso_code
                                    }), unique_by: [:bandcamp_url, :sku])
    end
  end

  task :load_rendered_services => :environment do
    require 'csv'

    ActiveRecord::Base.transaction do
      RenderedService.destroy_all

      artist_names = Album.distinct.pluck(:artist_name)
      strip = ->(v) { v&.strip }

      path = Rails.root.join('exports/FS SERVICES RENDERED - WORK LIST.csv')
      CSV.foreach(path, headers: true, converters: strip, header_converters: strip) do |row|
        next if row['NAME'].blank?

        date = Date.parse(row['DATE'])
        _, fsn = HomeSheetReport.parse_payee(row['FSN'])
        payee = Payee.find_by!(fsn: fsn)
        type = { 'amount' => :fixed, 'hourly' => :hourly }[row['COMPENSATION TYPE']]
        hours = row['amount / hours'].to_f if type == :hourly
        compensation = row['AMOUNT'].delete_prefix('$').strip.to_f.to_money
        albums = (row['ALBUMS'] || '').split('|').map do |n|
          unless n.strip.in?(Rails.application.config.app_config[:home_sheet][:splits][:skip_albums])
            Album.find_by!(name: n.strip)
          end
        end.compact
        artist_name = row['ARTIST'] if row['ARTIST'].in?(artist_names)

        if albums.empty?
          RenderedService.create!(
            type: type,
            payee: payee,
            compensation: compensation,
            description: row['PROJECT'],
            hours: hours,
            rendered_at: date,
            artist_name: artist_name,
            album: nil
          )
        else
          # divide the amount evenly amongst all albums
          albums.each do |album|
            RenderedService.create!(
              type: type,
              payee: payee,
              compensation: compensation / albums.count,
              description: row['PROJECT'],
              hours: hours,
              rendered_at: date,
              artist_name: artist_name,
              album: album
            )
          end
        end
      end
    end
  end

  task :load_internal_merch_orders => :environment do
    require 'roo'

    path = Rails.root.glob('exports/FOURTH STRIKE HOME SHEET*.xlsx').first
    xlsx = Roo::Spreadsheet.open(path.to_s)

    CalculatorCache::Manager.defer_recompute do
      ActiveRecord::Base.transaction do
        # Wipe any existing orders and re-create from scratch
        InternalMerchOrder.find_each do |order|
          order.destroy!
          order.payout.destroy!
          order.merch_fulfillment.destroy!
        end

        xlsx.sheet('INT MERCH ORDERS').parse(name: 'NAME', sku: 'MERCH SKU', out: 'OUT', in: 'IN',
                                             net: 'NET').each do |row|
          next if row[:name].blank?

          _, fsn = HomeSheetReport.parse_payee(row[:name])
          date = Time.zone.now # TODO: it would be awesome if we had an actual date for these
          cost = row[:in].to_money
          payee = Payee.find_by!(fsn: fsn)
          sku = row[:sku]
          if Rails.application.config.app_config[:home_sheet][:internal_merch][:sku_remap].key?(sku)
            sku = Rails.application.config.app_config[:home_sheet][:internal_merch][:sku_remap][sku]
          end
          merch = Merch.find_by!(sku: sku)

          InternalMerchOrder.create!(
            merch_item: merch,
            payout: Payout.new(
              payee: payee,
              amount: cost,
              paid_at: date,
              paypal_transaction_id: nil
            ),
            merch_fulfillment: MerchFulfillment.new(
              shipped_on: date,
              production_cost: cost,
              bandcamp_sale_id: nil
            )
          )
        end
      end
    end
  end

  task :load_patreon => :environment do
    require 'roo'
    path = Rails.root.join('exports/PATREON CALC.xlsx')
    xlsx = Roo::Spreadsheet.open(path.to_s)

    CalculatorCache::Manager.defer_recompute do
      ActiveRecord::Base.transaction do
        sheets = {
          'janCALC' => '2021-01-01',
          # 'febCALC' => '2021-02-01', # STOPSHIP
          'marCALC' => '2021-03-01',
          'aprCALC' => '2021-04-01',
          'mayCALC' => '2021-05-01',
          'junCALC' => '2021-06-01',
          'jul21CALC' => '2021-07-01',
          'aug21CALC' => '2021-08-01'
          # 'sep21CALC' => '2021-09-01',
          # 'oct21CALC' => '2021-10-01',
          # 'nov21CALC' => '2021-11-01',
        }

        settings = Rails.application.config.app_config[:patreon]
        tiers = settings[:tiers]
        products = settings[:products]

        sheets.each do |sheet_name, month|
          sheet = xlsx.sheet(sheet_name)

          month_config = products[month]
          raise StandardError, "No config for month: #{month}" if month_config.blank?

          sheet.each(name: 'Name', tier: 'Tier', pledge_amount: 'Pledge Amount',
                     weighted_amount: 'Altered').drop(1).each do |row|
            tier_config = tiers[row[:tier]]
            raise StandardError, "Unknown tier: #{row[:tier]}" if tier_config.blank?

            hashed_name = Digest::MD5.hexdigest(row[:name])
            digital_revenue = row[:weighted_amount].to_money('USD') * tier_config[:digital_distribution]
            physical_revenue = row[:weighted_amount].to_money('USD') - digital_revenue

            unless digital_revenue.zero?
              weighted = digital_revenue / month_config[:digital].count

              month_config[:digital].each do |album_name|
                album = Album.find_by!(name: album_name)

                PatreonSale.upsert({
                                     product_type: 'Album',
                                     product_id: album.id,
                                     period: month,
                                     tier: row[:tier],
                                     net_revenue_amount_cents: weighted.cents,
                                     net_revenue_amount_currency: weighted.currency.iso_code,
                                     customer_name_hashed: hashed_name
                                   }, unique_by: [:customer_name_hashed, :period, :product_type, :product_id])
              end
            end

            merch_items = tier_config[:merch].map { |type| Merch.find_by!(sku: month_config[type]) }
            weighted = physical_revenue / merch_items.count if merch_items.present?
            merch_items.each do |merch|
              PatreonSale.upsert({
                                   product_type: 'Merch',
                                   product_id: merch.id,
                                   period: month,
                                   tier: row[:tier],
                                   net_revenue_amount_cents: weighted.cents,
                                   net_revenue_amount_currency: weighted.currency.iso_code,
                                   customer_name_hashed: hashed_name
                                 }, unique_by: [:customer_name_hashed, :period, :product_type, :product_id])
            end
          end
        end
      end
    end
  end
end
# rubocop:enable Rails/SkipsModelValidations
