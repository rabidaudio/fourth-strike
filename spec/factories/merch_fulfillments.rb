# frozen_string_literal: true

# == Schema Information
#
# Table name: merch_fulfillments
#
#  id                       :integer          not null, primary key
#  production_cost_cents    :integer          default(0), not null
#  production_cost_currency :string           default("USD"), not null
#  shipped_on               :date
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  bandcamp_sale_id         :integer
#  fulfilled_by_id          :integer
#
# Indexes
#
#  index_merch_fulfillments_on_bandcamp_sale_id  (bandcamp_sale_id)
#  index_merch_fulfillments_on_fulfilled_by_id   (fulfilled_by_id)
#
# Foreign Keys
#
#  bandcamp_sale_id  (bandcamp_sale_id => bandcamp_sales.id)
#  fulfilled_by_id   (fulfilled_by_id => admins.id)
#
FactoryBot.define do
  factory :merch_fulfillment do
    bandcamp_sale { association(:bandcamp_sale, :merch) }

    production_cost { 6.78.to_money }

    shipped_on { bandcamp_sale.purchased_at + (0..4).to_a.sample.days }
    fulfilled_by { association(:admin) }
  end
end
