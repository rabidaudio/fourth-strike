# frozen_string_literal: true

# == Schema Information
#
# Table name: merch_items
#
#  id                  :integer          not null, primary key
#  artist_name         :string
#  bandcamp_url        :string           not null
#  list_price_cents    :integer          default(0), not null
#  list_price_currency :string           default("USD"), not null
#  name                :string           not null
#  sku                 :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_merch_items_on_bandcamp_url  (bandcamp_url) UNIQUE
#  index_merch_items_on_sku           (sku) UNIQUE
#
FactoryBot.define do
  factory :merch do
    transient do
      type { ['T', 'C', 'P'].sample }
      full_type { { 'T' => 'T-SHIRT', 'C' => 'CASSETTE', 'P' => 'POSTER' } }

      release { association(:album) }
    end

    name { "#{release.name.upcase} #{full_type}" }
    artist_name { release.artist_name }
    sku { "#{type}-#{release.catalog_number.take(3)}-#{Faker::Number.number(digits: 3)}" }
    list_price { ['T' => 23.33, 'C' => 23.33, 'P' => 9.99][type].to_money }
    bandcamp_url do
      [
        "https://#{FactoryUtils.sanitize_for_url(artist_name)}.bandcamp.com",
        'merch',
        "#{FactoryUtils.sanitize_for_url(name)}-#{Faker::Number.number(digits: 4)}"
      ].join('/')
    end
  end
end
