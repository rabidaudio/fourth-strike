# frozen_string_literal: true

class RemoveBandcampSaleIdFromMerchFulfillments < ActiveRecord::Migration[7.2]
  def change
    remove_reference :merch_fulfillments, :bandcamp_sale, null: true
  end
end
