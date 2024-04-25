# frozen_string_literal: true

# == Schema Information
#
# Table name: albums
#
#  id             :integer          not null, primary key
#  artist_name    :string           not null
#  bandcamp_url   :string           not null
#  catalog_number :string           not null
#  name           :string           not null
#  released_at    :datetime
#  upc            :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_albums_on_bandcamp_url    (bandcamp_url) UNIQUE
#  index_albums_on_catalog_number  (catalog_number) UNIQUE
#  index_albums_on_upc             (upc) UNIQUE
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
      "https://#{FactoryUtils.sanitize_for_url(artist_name)}.bandcamp.com/album/#{FactoryUtils.sanitize_for_url(name)}"
    end
    released_at { Faker::Date.backward(days: 365) }
    upc { Faker::Number.number(digits: 12).to_s }

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
