# frozen_string_literal: true

class CreateDistrokidSales < ActiveRecord::Migration[7.1]
  def change
    create_table :distrokid_sales do |t|
      t.date :sale_period
      t.date :reported_at
      t.string :store
      t.string :artist_name
      t.string :title
      t.string :isrc
      t.string :upc
      t.integer :quantity
      t.references :product, null: false, polymorphic: true
      t.numeric :earnings_usd

      t.timestamps
    end
    add_index :distrokid_sales, :reported_at
    add_index :distrokid_sales, :isrc
    add_index :distrokid_sales, :upc
  end
end
