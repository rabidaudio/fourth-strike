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

# A merch item is a physical product such as a t-shit or cassette
# which is sold via Bandcamp. Unlike digital sales, merch sales
# have to be fullfilled by indicating the cost of the product
# and shipping.
#
# Like albums and tracks, merch is identified on Bandcamp using
# its url. But all merch items also have a SKU. This is typically of the form
# [type]-[project](-number) where type can be:
# C: CD or cassette
# V: vinyl
# T: T-shirt or hoodie
# H: hoodie
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
class Merch < ApplicationRecord
  include Product

  self.table_name = 'merch_items'

  monetize :list_price_cents

  validates :list_price_currency, inclusion: { in: Money.default_currency.iso_code }
end
