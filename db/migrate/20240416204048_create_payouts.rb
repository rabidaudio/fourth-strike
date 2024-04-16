# frozen_string_literal: true

class CreatePayouts < ActiveRecord::Migration[7.1]
  def change
    create_table :payouts do |t|
      t.references :payee, null: false, foreign_key: true
      t.datetime :paid_at
      t.string :paypal_transaction_id
      t.monetize :amount

      t.timestamps
    end
    add_index :payouts, :paypal_transaction_id, unique: true
  end
end
