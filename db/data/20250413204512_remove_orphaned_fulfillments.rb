# frozen_string_literal: true

class RemoveOrphanedFulfillments < ActiveRecord::Migration[7.2]
  def up
    MerchFulfillment.find_each do |mf|
      next unless mf.bandcamp_sales.empty?
      next unless mf.internal_merch_order.nil?

      mf.destroy!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
