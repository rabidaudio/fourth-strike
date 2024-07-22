# frozen_string_literal: true

# == Schema Information
#
# Table name: internal_merch_orders
#
#  id                   :integer          not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  merch_fulfillment_id :integer          not null
#  merch_item_id        :integer          not null
#  payout_id            :integer          not null
#
# Indexes
#
#  index_internal_merch_orders_on_merch_fulfillment_id  (merch_fulfillment_id)
#  index_internal_merch_orders_on_merch_item_id         (merch_item_id)
#  index_internal_merch_orders_on_payout_id             (payout_id)
#
# Foreign Keys
#
#  merch_fulfillment_id  (merch_fulfillment_id => merch_fulfillments.id)
#  merch_item_id         (merch_item_id => merch_items.id)
#  payout_id             (payout_id => payouts.id)
#
FactoryBot.define do
  factory :internal_merch_order do
    merch_item

    transient do
      cost { merch_item.list_price / 2 }
    end

    merch_fulfillment do
      association(:merch_fulfillment,
                  bandcamp_sale: nil,
                  production_cost: cost,
                  fulfilled_by: nil,
                  shipped_on: Time.zone.now)
    end
    payout do
      association(:payout, paypal_transaction_id: nil, amount: cost)
    end
  end
end
