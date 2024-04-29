# frozen_string_literal: true

class LoosenPaypalUniqueConstraint < ActiveRecord::Migration[7.1]
  def change
    remove_index :payees, :paypal_account, unique: true
    add_index :payees, :paypal_account, unique: false
  end
end
