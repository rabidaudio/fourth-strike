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
FactoryBot.define do
  factory :distrokid_sale do
    sale_period { Faker::Time.between_dates(from: 3.years.ago, to: Time.zone.today).to_date.at_beginning_of_month }
    reported_at { Faker::Time.between_dates(from: sale_period, to: Time.zone.today).to_date }
    store do
      [
        'Amazon (downloads)',
        'Amazon Prime (streaming)',
        'Amazon Unlimited (streaming)',
        'Apple Music',
        'iTunes',
        'Pandora',
        'Spotify',
        'Tidal',
        'YouTube (Ads)',
        'YouTube (Audio)',
        'YouTube (Red)'
      ].sample
    end

    quantity { 100 }
    earnings_usd { 0.0035 * quantity }
    product { association(:track) }
    artist_name { product.album.artist_name }
    title { product.name }
    isrc { product.isrc }

    trait :album do
      product { association(:album) }
      store { 'iTunes' }
      title { product.name }
      artist_name { product.artist_name }
      quantity { 1 }
      earnings_usd { 9.99 }
      isrc { nil }
      upc { product.upcs.sample }
    end
  end
end
