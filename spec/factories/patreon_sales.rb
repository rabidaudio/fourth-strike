# frozen_string_literal: true

# == Schema Information
#
# Table name: patreon_sales
#
#  id                                  :integer          not null, primary key
#  customer_name_hashed                :string           not null
#  net_revenue_amount_cents            :integer          default(0), not null
#  net_revenue_amount_currency         :string           default("USD"), not null
#  period                              :date             not null
#  product_type                        :string           not null
#  proportional_pledge_amount_cents    :integer          default(0), not null
#  proportional_pledge_amount_currency :string           default("USD"), not null
#  tier                                :string           not null
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  product_id                          :integer          not null
#
# Indexes
#
#  idx_on_customer_name_hashed_period_product_type_pro_57f480592f  (customer_name_hashed,period,product_type,product_id) UNIQUE
#  index_patreon_sales_on_product                                  (product_type,product_id)
#
FactoryBot.define do
  factory :patreon_sale do
    customer_name_hashed { Digest::MD5.hexdigest(Faker::Name.name) }
    tier { Rails.application.config.app_config[:patreon][:tiers].keys.sample }
    month { (Date.parse('2021-01-01')...Date.parse('2021-12-01')).to_a.sample.at_beginning_of_month }

    product { association(:album) }
    net_revenue_amount { 3.50.to_money }

    trait :cassette do
      tier { 'Third Strike! (Cassettes)' }
      product { association(:merch, :cassette) }
    end

    trait :cassette do
      tier { 'Third Strike! (T-Shirts)' }
      product { association(:merch, :tshirt) }
    end
  end
end
