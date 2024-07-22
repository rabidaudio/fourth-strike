# frozen_string_literal: true

class SupportInternalMerchOrders < ActiveRecord::Migration[7.1]
  def change
    change_column_null :merch_fulfillments, :bandcamp_sale_id, true
  end
end
