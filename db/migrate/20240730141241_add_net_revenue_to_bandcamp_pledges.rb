# frozen_string_literal: true

class AddNetRevenueToBandcampPledges < ActiveRecord::Migration[7.1]
  def change
    add_monetize :bandcamp_pledges, :net_revenue_amount
    add_reference :bandcamp_pledges, :product, polymorphic: true
    add_column :bandcamp_pledges, :funded_at, :datetime, null: false # rubocop:disable Rails/NotNullColumn
  end
end
