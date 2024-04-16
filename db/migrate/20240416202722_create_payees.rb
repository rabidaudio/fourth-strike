# frozen_string_literal: true

class CreatePayees < ActiveRecord::Migration[7.1]
  def change
    remove_column :artists, :paypal_account, type: :string
    create_table :payees do |t|
      t.string :paypal_account

      t.timestamps
    end
    add_index :payees, :paypal_account, unique: true

    add_reference :artists, :payee, foreign_key: true
  end
end
