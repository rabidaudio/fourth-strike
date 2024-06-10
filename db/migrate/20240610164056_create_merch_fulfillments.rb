# frozen_string_literal: true

class CreateMerchFulfillments < ActiveRecord::Migration[7.1]
  def change
    create_table :merch_fulfillments do |t|
      t.references :bandcamp_sale, null: false, foreign_key: true
      t.monetize :production_cost
      t.date :shipped_on
      t.references :fulfilled_by, foreign_key: { to_table: :admins }

      t.timestamps
    end
  end
end
