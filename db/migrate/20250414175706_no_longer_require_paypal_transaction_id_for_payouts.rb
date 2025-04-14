# frozen_string_literal: true

class NoLongerRequirePaypalTransactionIdForPayouts < ActiveRecord::Migration[7.2]
  def change
    remove_index :payouts, :paypal_transaction_id, unique: true
    add_column :payouts, :note, :text, null: true
  end
end
