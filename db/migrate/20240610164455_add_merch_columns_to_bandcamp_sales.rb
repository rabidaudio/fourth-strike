# frozen_string_literal: true

class AddMerchColumnsToBandcampSales < ActiveRecord::Migration[7.1]
  def change
    add_column :bandcamp_sales, :option, :string
  end
end
