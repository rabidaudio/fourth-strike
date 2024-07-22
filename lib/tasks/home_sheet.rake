# frozen_string_literal: true

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
end
