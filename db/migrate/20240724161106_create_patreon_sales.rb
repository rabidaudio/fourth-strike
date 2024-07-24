# frozen_string_literal: true

class CreatePatreonSales < ActiveRecord::Migration[7.1]
  def change
    create_table :patreon_sales do |t|
      t.references :product, null: false, polymorphic: true
      t.date :period, null: false
      t.string :customer_name_hashed, null: false
      t.string :tier, null: false
      t.monetize :net_revenue_amount

      t.timestamps
    end

    add_index :patreon_sales, [:customer_name_hashed, :period, :product_type, :product_id], unique: true
  end
end
