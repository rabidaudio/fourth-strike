# frozen_string_literal: true

# == Schema Information
#
# Table name: merch_fulfillments
#
#  id                       :integer          not null, primary key
#  notes                    :text
#  printify_order_number    :string
#  production_cost_cents    :integer          default(0), not null
#  production_cost_currency :string           default("USD"), not null
#  shipped_on               :date
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  fulfilled_by_id          :integer
#
# Indexes
#
#  index_merch_fulfillments_on_fulfilled_by_id  (fulfilled_by_id)
#
# Foreign Keys
#
#  fulfilled_by_id  (fulfilled_by_id => admins.id)
#
FactoryBot.define do
  factory :merch_fulfillment do
    bandcamp_sales { [association(:bandcamp_sale, :merch)] }
    production_cost { 6.78.to_money }

    shipped_on { (bandcamp_sales.first&.purchased_at || Time.zone.now) + (0..4).to_a.sample.days }
    fulfilled_by { association(:admin) }
  end
end
