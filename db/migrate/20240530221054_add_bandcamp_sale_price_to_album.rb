# frozen_string_literal: true

class AddBandcampSalePriceToAlbum < ActiveRecord::Migration[7.1]
  def change
    add_monetize :albums, :bandcamp_price
  end
end
