# frozen_string_literal: true

class MakeBandcampSaleUniqueByIdAndItem < ActiveRecord::Migration[7.1]
  def change
    remove_index :bandcamp_sales, :bandcamp_transaction_id, unique: true
    add_index :bandcamp_sales, [:bandcamp_transaction_id, :item_url], unique: true
  end
end
