# frozen_string_literal: true

# == Schema Information
#
# Table name: contributions
#
#  id            :integer          not null, primary key
#  details       :text
#  is_songwriter :boolean          default(FALSE), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  artist_id     :integer          not null
#  track_id      :integer          not null
#
# Indexes
#
#  index_contributions_on_artist_id               (artist_id)
#  index_contributions_on_track_id                (track_id)
#  index_contributions_on_track_id_and_artist_id  (track_id,artist_id) UNIQUE
#
# Foreign Keys
#
#  artist_id  (artist_id => artists.id)
#  track_id   (track_id => tracks.id)
#
# A list of Artists who contributed to a Track.
# `is_songwriter` flags if the Artist should be credited as
# writing a track, rather than simply contributing an additional
# part. Typically, streaming revenue for a track goes to songwriters
# only, and album sales go to all contributors to any song on the album.
# `details` describes the contribution (e.g. "guitar, additional vocals").
class Contribution < ApplicationRecord
  belongs_to :track
  belongs_to :artist

  scope :songwriters, -> { where(is_songwriter: true) }

  def songwriter?
    is_songwriter
  end
end
