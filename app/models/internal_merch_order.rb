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
#
# For a while, we allowed artists to have their royalties paid out in at-cost
# merch items. To account for this, we create a merch fulfillment and a payout
# without a paypal id of the production cost of the merch.
class InternalMerchOrder < ApplicationRecord
  belongs_to :merch_item, class_name: 'Merch'
  belongs_to :payout, dependent: :destroy
  belongs_to :merch_fulfillment, dependent: :destroy
  has_one :payee, through: :payout

  accepts_nested_attributes_for :payout
  accepts_nested_attributes_for :merch_fulfillment
end
