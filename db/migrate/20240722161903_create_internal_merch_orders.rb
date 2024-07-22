# frozen_string_literal: true

class CreateInternalMerchOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :internal_merch_orders do |t|
      t.references :payout, null: false, foreign_key: true
      t.references :merch_item, null: false, foreign_key: true
      t.references :merch_fulfillment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
