# frozen_string_literal: true

# == Schema Information
#
# Table name: distrokid_sales
#
#  id           :integer          not null, primary key
#  artist_name  :string
#  earnings_usd :decimal(, )
#  isrc         :string
#  product_type :string           not null
#  quantity     :integer
#  reported_at  :date
#  sale_period  :date
#  store        :string
#  title        :string
#  upc          :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  product_id   :integer          not null
#
# Indexes
#
#  index_distrokid_sales_on_isrc         (isrc)
#  index_distrokid_sales_on_product      (product_type,product_id)
#  index_distrokid_sales_on_reported_at  (reported_at)
#  index_distrokid_sales_on_upc          (upc)
#

# A sale of digital music through Distrokid. This is typically streaming revenue from a single track.
# However, it also includes some album and track sales from alternative stores (e.g. iTunes).
#
# earnings_usd: The amount of revenue paid out by Distrokid after fees, in fractional US Dollars.
#  NOTE: Not a Money instance, as it needs to store fractional cents (since streaming revenues are so small)
# ISRC: A unique id for tracks.
# UPC: A unique id for both tracks and albums.
# store: where the sale was made (Spotify, iTunes, Google Play, etc)
# sale_period: The month during which the purchase happened. A date field of the first of the month.
# quantity: the number of streams/sales in that sale period
# reported_at: the date it was actually recorded by Distrokid. The stores can have a long delay
#   between recording a sale and reporting it to Distrokid. This is the date we use for
#   calculating when a royalty payout was due (because that's when funds were available to the org)
# artist_name/title: the name of the album or track that was sold
class DistrokidSale < ApplicationRecord
  include Sale

  # NOTE: this list isn't complete, but it's the most important ones
  scope :streaming, lambda {
                      where(store: [
                              'Amazon Prime (streaming)',
                              'Amazon Unlimited (streaming)',
                              'Apple Music',
                              'Pandora',
                              'Spotify',
                              'Tidal',
                              'Facebook',
                              'Deezer',
                              'Resso',
                              'TikTok',
                              'YouTube (Audio)',
                              'YouTube (Red)'
                            ])
                    }

  scope :streams_per_month, -> { streaming.group(:sale_period).sum(:quantity) }

  validates :product_type,
            inclusion: { in: ['Album', 'Track'], message: '%{value} cannot be sold through Distrokid' }
end
