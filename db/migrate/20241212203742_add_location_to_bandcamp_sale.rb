# frozen_string_literal: true

class AddLocationToBandcampSale < ActiveRecord::Migration[7.2]
  def change
    add_column :bandcamp_sales, :shipping_destination, :string
    add_column :bandcamp_sales, :refunded, :boolean, null: false, default: false
  end
end
