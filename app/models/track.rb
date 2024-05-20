# frozen_string_literal: true

# == Schema Information
#
# Table name: tracks
#
#  id           :integer          not null, primary key
#  bandcamp_url :string           not null
#  credits      :text
#  isrc         :string
#  lyrics       :text
#  name         :string           not null
#  track_number :integer          not null
#  upc          :string
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
#  index_tracks_on_upc                        (upc) UNIQUE
#
# Foreign Keys
#
#  album_id  (album_id => albums.id)
#

# A track is a single song from an Album. Tracks have their own contributor splits
# indepedent from Albums (which are used for individual track sales and streaming credits).
# Distrokid identifies albums by ISRC (or UPC). Bandcamp does not have IDs for tracks.
# Rather than matching on names, we use the Bandcamp URL as the unique identifier
# for correlating with Bandcamp data.
# Lyrics and Credits are used for informational purposes only.
class Track < ApplicationRecord
  include Product

  strip_attributes

  belongs_to :album

  validates :track_number, numericality: { greater_than_or_equal_to: 1 }

  def total_streams(from: Time.zone.at(0), to: Time.zone.now)
    distrokid_sales.streaming.where('reported_at >= ?', from).where('reported_at < ?', to).sum(:quantity)
  end
end
