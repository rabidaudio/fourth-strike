# frozen_string_literal: true

# == Schema Information
#
# Table name: merch_items
#
#  id                   :integer          not null, primary key
#  artist_name          :string
#  bandcamp_url         :string
#  external_distributor :integer          default("undefined"), not null
#  list_price_cents     :integer          default(0), not null
#  list_price_currency  :string           default("USD"), not null
#  name                 :string           not null
#  private              :boolean          default(FALSE), not null
#  sku                  :string           not null
#  variants             :string           default("[]"), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  album_id             :integer
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

# A merch item is a physical product such as a t-shit or cassette
# which is sold via Bandcamp. Unlike digital sales, merch sales
# have to be fullfilled by indicating the cost of the product
# and shipping.
#
# Merch can optionally be associated with an album. This is for tracking purposes only;
# merch has its own splits, like tracks do (although in this case they will likely match
# the album splits).
#
# Like albums and tracks, merch is identified on Bandcamp using
# its url. But all merch items also have a SKU. This is typically of the form
# [type]-[project](-number) where type can be:
# C: CD or cassette
# V: vinyl
# T: T-shirt or hoodie
# H: patch or hoodie
# M: mug
# B: badge
# S: sticker
# P: poster
# X: something else
#
# However, there are a number of exceptions to this rule.
# Project is an indicator of which, usually connected to an album sku/catalog number.
# List price is the price on bandcamp, which is not necessarily what the user paid
# due to discounts, the patreon, additional contributions, etc.
# Variants is a JSON array of information about the variants available (e.g. size, color, etc).
# NOTE: for physical versions of albums on Bancamp, such as cassettes, the url for the merch is the
# album itself.
class Merch < ApplicationRecord
  include Product
  include JsonStringColumn

  self.table_name = 'merch_items'

  belongs_to :album, optional: true
  has_many :merch_fulfillments, through: :bandcamp_sales

  monetize :list_price_cents

  json_string_attributes :variants

  enum :external_distributor,
       undefined: 0,
       iam8bit: 1

  validates :list_price_currency, inclusion: { in: Money.default_currency.iso_code }
  validates :artist_name, inclusion: { in: -> { Album.distinct.pluck(:artist_name) }, allow_nil: true }

  def private?
    attributes['private']
  end
end
