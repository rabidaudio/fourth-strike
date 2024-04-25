# frozen_string_literal: true

# == Schema Information
#
# Table name: bandcamp_sales
#
#  id                          :integer          not null, primary key
#  item_url                    :string           not null
#  net_revenue_amount_cents    :integer          default(0), not null
#  net_revenue_amount_currency :string           default("USD"), not null
#  notes                       :text
#  purchased_at                :datetime         not null
#  quantity                    :integer          not null
#  sku                         :string
#  splittable_type             :string           not null
#  subtotal_amount_cents       :integer          default(0), not null
#  subtotal_amount_currency    :string           default("USD"), not null
#  type                        :integer          not null
#  upc                         :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  bandcamp_transaction_id     :string
#  paypal_transaction_id       :string
#  splittable_id               :integer          not null
#
# Indexes
#
#  index_bandcamp_sales_on_bandcamp_transaction_id  (bandcamp_transaction_id) UNIQUE
#  index_bandcamp_sales_on_item_url                 (item_url)
#  index_bandcamp_sales_on_paypal_transaction_id    (paypal_transaction_id)
#  index_bandcamp_sales_on_splittable               (splittable_type,splittable_id)
#  index_bandcamp_sales_on_upc                      (upc)
#
FactoryBot.define do
  factory :bandcamp_sale do
    quantity { 1 }
    bandcamp_transaction_id { Faker::Number.number(digits: 10).to_s }
    paypal_transaction_id { nil }
    net_revenue_amount { (subtotal_amount * 0.85) - 0.15.to_money }
    item_url { splittable.bandcamp_url }
    purchased_at { Faker::Date.backward(days: 30) }

    trait :album do
      type { :album }
      splittable { association(:album) }

      upc { Faker::Number.number(digits: 12).to_s }

      subtotal_amount { 6.66.to_money * quantity }
    end

    trait :track do
      type { :track }
      splittable { association(:track) }

      upc { splittable.upc }

      subtotal_amount { 1.11 * quantity }
    end
  end
end
