# frozen_string_literal: true

class AddNotesToMerchFulfillment < ActiveRecord::Migration[7.1]
  def change
    add_column :merch_fulfillments, :printify_order_number, :string
    add_column :merch_fulfillments, :notes, :text
  end
end
