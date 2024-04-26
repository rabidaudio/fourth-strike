# frozen_string_literal: true

# == Schema Information
#
# Table name: albums
#
#  id             :integer          not null, primary key
#  album_art_url  :string
#  artist_name    :string           not null
#  bandcamp_url   :string           not null
#  catalog_number :string
#  name           :string           not null
#  release_date   :date
#  upc            :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_albums_on_bandcamp_url    (bandcamp_url) UNIQUE
#  index_albums_on_catalog_number  (catalog_number) UNIQUE
#  index_albums_on_upc             (upc) UNIQUE
#

# Albums are collections of tracks. They have their own splits distinct
# from tracks. Album artists are strings (e.g. "the garages"), not Artist
# models (which are really contributors), which might but generally won't be 1-to-1.
# The association with tracks is purely for informational purposes, in practice
# it doesn't effect the computing of royalties. Theoretically an album could have
# no tracks and everything would work as expected.
# Distrokid identifies albums by UPC. Bandcamp does not have IDs for albums.
# Rather than matching on names, we use the Bandcamp URL as the unique identifier
# for correlating with Bandcamp data.
class Album < ApplicationRecord
  include Product

  strip_attributes

  has_many :tracks, dependent: :restrict_with_exception

  validates :catalog_number, format: { with: /\A[A-Z]{3}-[0-9]{3}\z/, allow_nil: true }
end
