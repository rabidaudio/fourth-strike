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
#  private                 :boolean          default(FALSE), not null
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

# Albums are collections of tracks. They have their own splits distinct
# from tracks. Album artists are strings (e.g. "the garages"), not Artist
# models (which are really contributors), which might but generally won't be 1-to-1.
# The association with tracks is purely for informational purposes, in practice
# it doesn't effect the computing of royalties. Theoretically an album could have
# no tracks and everything would work as expected.
# Distrokid identifies albums by UPC. Bandcamp does not have IDs for albums.
# Rather than matching on names, we use the Bandcamp URL as the unique identifier
# for correlating with Bandcamp data.
# The same album can be uploaded under multiple versions to different streaming platforms,
# so an album can have more than one UPC.
class Album < ApplicationRecord
  include Product
  include JsonStringColumn
  include MonitizedSum

  strip_attributes except: [:upcs]
  json_string_attributes :upcs

  monetize :bandcamp_price_cents

  has_many :tracks, dependent: :restrict_with_exception
  has_many :merch_items, class_name: 'Merch', dependent: :restrict_with_exception
  has_many :rendered_services, dependent: :restrict_with_exception

  validates :catalog_number, format: { with: /\A[A-Z]{3}-[0-9]{3}\z/, allow_nil: true }

  def self.find_by_upc(upc)
    where('upcs like ?', "%\"#{upc}\"%").first
  end

  def digital_sale_revenue
    RoyaltyCalculator.new(self).digital_revenue
  end

  def streaming_revenue
    tracks.map { |t| RoyaltyCalculator.new(t).digital_revenue }.sum
  end

  def merch_revenue
    return 0.to_money if merch_items.empty?

    merch_items.map { |t| RoyaltyCalculator.new(t).gross_revenue }.sum
  end

  def total_associated_revenue
    digital_sale_revenue + streaming_revenue + merch_revenue
  end

  def expenses
    RoyaltyCalculator.new(self).upfront_costs
  end

  def royalties
    RoyaltyCalculator.new(self).total_royalties_owed +
      tracks.map { |t| RoyaltyCalculator.new(t).total_royalties_owed }.sum +
      merch_items.map { |t| RoyaltyCalculator.new(t).total_royalties_owed }.sum
  end

  def profit
    RoyaltyCalculator.new(self).organization_income +
      tracks.map { |t| RoyaltyCalculator.new(t).organization_income }.sum +
      merch_items.map { |t| RoyaltyCalculator.new(t).organization_income }.sum
  end

  def negative?
    expenses > total_associated_revenue
  end

  def private?
    attributes['private']
  end
end
