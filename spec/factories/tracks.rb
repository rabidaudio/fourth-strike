# frozen_string_literal: true

# == Schema Information
#
# Table name: tracks
#
#  id           :integer          not null, primary key
#  bandcamp_url :string
#  credits      :text
#  isrc         :string
#  lyrics       :text
#  name         :string           not null
#  track_number :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  album_id     :integer          not null
#  bandcamp_id  :string
#
# Indexes
#
#  index_tracks_on_album_id                   (album_id)
#  index_tracks_on_album_id_and_track_number  (album_id,track_number) UNIQUE
#  index_tracks_on_bandcamp_id                (bandcamp_id) UNIQUE
#  index_tracks_on_bandcamp_url               (bandcamp_url) UNIQUE
#  index_tracks_on_isrc                       (isrc) UNIQUE
#
# Foreign Keys
#
#  album_id  (album_id => albums.id)
#
FactoryBot.define do
  factory :track do
    name { Faker::Music::RockBand.song }
    album
    track_number { 1 }
    isrc { Faker::Code.nric }
    lyrics { Faker::Lorem.paragraphs(number: 4) }
    credits { Faker::Lorem.sentence }
    bandcamp_url do
      [
        "https://#{FactoryUtils.sanitize_for_url(album.artist_name)}.bandcamp.com",
        'track',
        "#{FactoryUtils.sanitize_for_url(name)}-#{Faker::Number.number(digits: 4)}"
      ].join('/')
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
