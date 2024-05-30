# frozen_string_literal: true

# Handles parsing of the DistroKid TSV report
# rubocop:disable Rails/Output
class DistrokidReport
  def self.upsert_all!(path)
    ActiveRecord::Base.transaction do
      # There isn't a good uniqueness for rows (it would be a combination of several), so instead
      # we just assume we're loading all data, and wipe and reload the whole table.
      DistrokidSale.delete_all

      CSV.foreach(path, headers: true, col_sep: "\t", liberal_parsing: true, encoding: 'iso-8859-1') do |row|
        DistrokidReport::Row.new(row).record_sale!
      end
    end
  end

  # A wrapper for a row object
  class Row
    attr_reader :row

    def initialize(row)
      @row = row
    end

    def product
      @product ||= if row['Song/Album'] == 'Album'
                     find_album_by_upc || find_album_by_name
                   elsif row['Song/Album'] == 'Song'
                     find_track_by_isrc || find_track_by_name
                   else
                     raise StandardError, 'Unknown type'
                   end
    end

    def return?
      quantity.negative? || earnings_usd.negative?
    end

    def record_sale!
      if product.nil?
        if skipped_artist?
          puts("Skipping #{row['Artist']} | #{row['Title']}")
          return
        end

        raise StandardError, "Unknown product: #{row['Title']}"
      end

      if return?
        puts("skipping return of #{row['Title']} (#{earnings_usd})")
        return
      end
      validate!
      DistrokidSale.create!(
        artist_name: row['Artist'],
        title: row['Title'],
        isrc: row['ISRC'],
        upc: row['UPC'],
        store: row['Store'],
        quantity: quantity,
        product: product,
        earnings_usd: earnings_usd,
        reported_at: reported_at,
        sale_period: sale_period
      )
    end

    private

    def skipped_artist?
      row['Artist'].in?(Rails.application.config.app_config[:distrokid][:skip][:artists])
    end

    def reported_at
      Date.parse(row['Reporting Date'])
    end

    def sale_period
      Date.strptime(row['Sale Month'], '%Y-%m')
    end

    def quantity
      row['Quantity'].to_i
    end

    def earnings_usd
      row['Earnings (USD)'].to_f
    end

    def validate!
      if row['Songwriter Royalties Withheld'] != '0'
        raise StandardError, "Songwriter royalties were withheld; we don't have logic to account for this"
      end

      if row['Team Percentage'] != '100'
        raise StandardError, "Team percentage was not 100%; we don't have logic to account for this"
      end
    end

    def find_album_by_upc
      return if row['UPC'].blank?

      Album.find_by_upc(row['UPC']) # rubocop:disable Rails/DynamicFindBy
    end

    def find_album_by_name
      Album.where('lower(name) = ? and lower(artist_name) = ?', row['Title'].downcase, row['Artist'].downcase).first
    end

    def find_track_by_isrc
      return if row['ISRC'].blank?

      Track.find_by(isrc: row['ISRC'])
    end

    def find_track_by_name
      Track.joins(:album).where('lower(albums.artist_name) = ? and lower(tracks.name) = ?', row['Artist'].downcase,
                                row['Title'].downcase).first
    end
  end
end
# rubocop:enable Rails/Output
