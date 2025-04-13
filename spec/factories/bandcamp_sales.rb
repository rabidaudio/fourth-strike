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
#  option                      :string
#  product_type                :string           not null
#  purchased_at                :datetime         not null
#  quantity                    :integer          not null
#  refunded                    :boolean          default(FALSE), not null
#  shipping_destination        :string
#  sku                         :string
#  subtotal_amount_cents       :integer          default(0), not null
#  subtotal_amount_currency    :string           default("USD"), not null
#  upc                         :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  bandcamp_transaction_id     :string
#  merch_fulfillment_id        :integer
#  paypal_transaction_id       :string
#  product_id                  :integer          not null
#
# Indexes
#
#  index_bandcamp_sales_on_bandcamp_transaction_id_and_item_url  (bandcamp_transaction_id,item_url) UNIQUE
#  index_bandcamp_sales_on_item_url                              (item_url)
#  index_bandcamp_sales_on_merch_fulfillment_id                  (merch_fulfillment_id)
#  index_bandcamp_sales_on_paypal_transaction_id                 (paypal_transaction_id)
#  index_bandcamp_sales_on_product                               (product_type,product_id)
#  index_bandcamp_sales_on_upc                                   (upc)
#
# Foreign Keys
#
#  merch_fulfillment_id  (merch_fulfillment_id => merch_fulfillments.id)
#
FactoryBot.define do
  factory :bandcamp_sale do
    quantity { 1 }
    bandcamp_transaction_id { Faker::Number.number(digits: 10).to_s }
    paypal_transaction_id { nil }
    # simulate bandcamp cut and transaction fee
    net_revenue_amount { (subtotal_amount * 0.85) - 0.15.to_money }
    item_url { product.bandcamp_url }
    purchased_at { Faker::Date.backward(days: 30) }

    trait :album do
      product { association(:album) }

      upc { product.upcs.sample }

      subtotal_amount { 6.66.to_money * quantity }
    end

    trait :track do
      product { association(:track) }

      subtotal_amount { 1.11 * quantity }
    end

    trait :merch do
      product { association(:merch) }

      option { ['small', 'medium', 'large', 'x-large'].sample }
    end

    trait :fulfilled do
      merch

      subtotal_amount { merch.list_price }

      merch_fulfillment { association(:merch_fulfillment) }
    end
  end
end
