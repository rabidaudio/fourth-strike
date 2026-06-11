# frozen_string_literal: true

class CreatePayoutRules < ActiveRecord::Migration[8.0]
  def change
    create_table :payout_rules do |t|
      t.references :source_payee, null: false, foreign_key: { to_table: :payees }
      t.references :target_payee, null: false, foreign_key: { to_table: :payees }
      t.datetime :starts_at
      t.datetime :ends_at

      t.timestamps
    end
  end
end
