# frozen_string_literal: true

class CreateBandcampSales < ActiveRecord::Migration[7.1]
  def change
    create_table :bandcamp_sales do |t|
      t.integer :type, null: false
      t.integer :quantity, null: false
      t.text :notes
      t.string :item_url, null: false
      t.string :sku
      t.string :upc
      t.string :bandcamp_transaction_id
      t.string :paypal_transaction_id
      t.monetize :subtotal_amount
      t.monetize :net_revenue_amount
      t.timestamp :purchased_at, null: false
      t.references :splittable, null: false, polymorphic: true

      t.timestamps
    end
    add_index :bandcamp_sales, :item_url
    add_index :bandcamp_sales, :upc
    add_index :bandcamp_sales, :bandcamp_transaction_id, unique: true
    add_index :bandcamp_sales, :paypal_transaction_id
  end
end
