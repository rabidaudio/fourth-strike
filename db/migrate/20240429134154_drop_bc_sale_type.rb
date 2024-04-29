# frozen_string_literal: true

class DropBcSaleType < ActiveRecord::Migration[7.1]
  def change
    remove_column :bandcamp_sales, :type, type: :integer, null: false
  end
end
