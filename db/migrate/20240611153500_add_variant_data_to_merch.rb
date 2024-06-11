# frozen_string_literal: true

class AddVariantDataToMerch < ActiveRecord::Migration[7.1]
  def change
    add_column :merch_items, :variants, :string, null: false, default: '[]'
    add_column :merch_items, :private, :boolean, null: false, default: false

    remove_index :merch_items, :sku, unique: true
    remove_index :merch_items, :bandcamp_url, unique: true
    add_index :merch_items, [:bandcamp_url, :sku], unique: true
  end
end
