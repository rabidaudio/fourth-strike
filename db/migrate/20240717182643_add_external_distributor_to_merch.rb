# frozen_string_literal: true

class AddExternalDistributorToMerch < ActiveRecord::Migration[7.1]
  def change
    add_column :merch_items, :external_distributor, :integer, null: false, default: 0
  end
end
