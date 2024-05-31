# frozen_string_literal: true

# == Schema Information
#
# Table name: albums
#
#  id                      :integer          not null, primary key
#  album_art_url           :string
#  artist_name             :string           not null
#  bandcamp_price_cents    :integer          default(0), not null
#  bandcamp_price_currency :string           default("USD"), not null
#  bandcamp_url            :string           not null
#  catalog_number          :string
#  name                    :string           not null
#  release_date            :date
#  upcs                    :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  bandcamp_id             :string
#
# Indexes
#
#  index_albums_on_bandcamp_id     (bandcamp_id) UNIQUE
#  index_albums_on_bandcamp_url    (bandcamp_url) UNIQUE
#  index_albums_on_catalog_number  (catalog_number) UNIQUE
#
FactoryBot.define do
  sequence :catalog_number do |n|
    [n.to_s.rjust(3, '0').chars.map { |c| (c.to_i + 'a'.ord).chr }.join.upcase, '-001'].join
  end

  factory :album do
    name { Faker::Music.album }
    catalog_number
    artist_name { Faker::Music::RockBand.name }
    bandcamp_url do
      [
        "https://#{FactoryUtils.sanitize_for_url(artist_name)}.bandcamp.com",
        'album',
        "#{FactoryUtils.sanitize_for_url(name)}-#{Faker::Number.number(digits: 4)}"
      ].join('/')
    end
    release_date { Faker::Date.backward(days: 365) }
    upcs { [Faker::Number.number(digits: 12).to_s] }

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
