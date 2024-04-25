# frozen_string_literal: true

class RenameSplittableToProduct < ActiveRecord::Migration[7.1]
  def change
    rename_column :splits, :splittable_id, :product_id
    rename_column :splits, :splittable_type, :product_type
    rename_index :splits, 'index_splits_on_splittable', 'index_splits_on_product'

    rename_column :bandcamp_sales, :splittable_id, :product_id
    rename_column :bandcamp_sales, :splittable_type, :product_type
    rename_index :bandcamp_sales, 'index_bandcamp_sales_on_splittable', 'index_bandcamp_sales_on_product'
  end
end
