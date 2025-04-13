# frozen_string_literal: true

class MoveMerchFulfillmentFksToBcSale < ActiveRecord::Migration[7.2]
  def up
    MerchFulfillment.where.not(bandcamp_sale_id: nil).find_each do |mf|
      BandcampSale.find(mf.bandcamp_sale_id).update!(merch_fulfillment_id: mf.id)
    end
  end

  def down
    BandcampSale.where.not(merch_fulfillment_id: nil).find_each do |bc|
      MerchFulfillment.find(bc.merch_fulfillment_id).update!(bandcamp_sale_id: bc.id)
    end
  end
end
