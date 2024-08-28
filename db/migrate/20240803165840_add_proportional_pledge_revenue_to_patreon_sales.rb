# frozen_string_literal: true

class AddProportionalPledgeRevenueToPatreonSales < ActiveRecord::Migration[7.1]
  def change
    add_monetize :patreon_sales, :proportional_pledge_amount
  end
end
