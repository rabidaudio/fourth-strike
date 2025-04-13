# frozen_string_literal: true

class MoveMerchFulfillmentToBandcampSale < ActiveRecord::Migration[7.2]
  def change
    add_reference :bandcamp_sales, :merch_fulfillment, null: true, foreign_key: true
    # TODO: remove merch_fulfillments.bandcamp_sale_id after
  end
end
