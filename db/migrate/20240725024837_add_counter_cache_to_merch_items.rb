# frozen_string_literal: true

class AddCounterCacheToMerchItems < ActiveRecord::Migration[7.1]
  def change
    add_column :merch_items, :albums_count, :integer, null: false, default: 0
  end
end
