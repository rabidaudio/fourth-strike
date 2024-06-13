# frozen_string_literal: true

class AllowNullMerchBandcampUrl < ActiveRecord::Migration[7.1]
  def change
    change_column_null :merch_items, :bandcamp_url, true
  end
end
