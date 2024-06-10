# frozen_string_literal: true

class CreateMerchItems < ActiveRecord::Migration[7.1]
  def change
    create_table :merch_items do |t|
      t.string :name, null: false
      t.string :sku, null: false
      t.string :bandcamp_url, null: false
      t.string :artist_name
      t.monetize :list_price

      t.timestamps
    end

    add_index :merch_items, :sku, unique: true
    add_index :merch_items, :bandcamp_url, unique: true
  end
end
