# frozen_string_literal: true

# == Schema Information
#
# Table name: merch_items
#
#  id                  :integer          not null, primary key
#  artist_name         :string
#  bandcamp_url        :string
#  list_price_cents    :integer          default(0), not null
#  list_price_currency :string           default("USD"), not null
#  name                :string           not null
#  private             :boolean          default(FALSE), not null
#  sku                 :string           not null
#  variants            :string           default("[]"), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  album_id            :integer
#
# Indexes
#
#  index_merch_items_on_album_id              (album_id)
#  index_merch_items_on_bandcamp_url_and_sku  (bandcamp_url,sku) UNIQUE
#
# Foreign Keys
#
#  album_id  (album_id => albums.id)
#
FactoryBot.define do
  factory :merch do
    transient do
      type { ['T', 'C', 'P'].sample }
      full_type { { 'T' => 'T-SHIRT', 'C' => 'CASSETTE', 'P' => 'POSTER' } }
    end

    album
    name { "#{album.name.upcase} #{full_type}" }
    artist_name { album.artist_name }
    sku { "#{type}-#{album.catalog_number[..2]}-#{Faker::Number.number(digits: 3)}" }
    list_price { ['T' => 23.33, 'C' => 23.33, 'P' => 6.66][type].to_money }
    bandcamp_url do
      [
        "https://#{FactoryUtils.sanitize_for_url(artist_name)}.bandcamp.com",
        'merch',
        "#{FactoryUtils.sanitize_for_url(name)}-#{Faker::Number.number(digits: 4)}"
      ].join('/')
    end

    trait :tshirt do
      type { 'T' }
    end

    trait :cassette do
      type { 'C' }
    end

    trait :poster do
      type { 'P' }
    end

    trait :with_splits do
      transient do
        distribution do
          { association(:payee) => 1, association(:payee) => 1 }
        end
      end

      splits do
        distribution.map do |payee, value|
          association(:split, payee: payee, value: value, product: instance)
        end
      end
    end
  end
end
