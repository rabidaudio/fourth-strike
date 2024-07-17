# frozen_string_literal: true

class CreateIam8bitSales < ActiveRecord::Migration[7.1]
  def change
    create_table :iam8bit_sales do |t|
      t.date :period, null: false
      t.string :name, null: false
      t.integer :quantity, null: false
      t.references :product, null: false, polymorphic: true
      t.monetize :gross_revenue_amount
      t.monetize :net_revenue_amount

      t.timestamps
    end
    add_index :iam8bit_sales, [:period, :name], unique: true
  end
end
