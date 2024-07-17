# frozen_string_literal: true

# == Schema Information
#
# Table name: iam8bit_sales
#
#  id                            :integer          not null, primary key
#  gross_revenue_amount_cents    :integer          default(0), not null
#  gross_revenue_amount_currency :string           default("USD"), not null
#  name                          :string           not null
#  net_revenue_amount_cents      :integer          default(0), not null
#  net_revenue_amount_currency   :string           default("USD"), not null
#  period                        :date             not null
#  product_type                  :string           not null
#  quantity                      :integer          not null
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  product_id                    :integer          not null
#
# Indexes
#
#  index_iam8bit_sales_on_period_and_name  (period,name) UNIQUE
#  index_iam8bit_sales_on_product          (product_type,product_id)
#
FactoryBot.define do
  factory :iam8bit_sale do
    product { association(:merch, :vinyl) }
    period { Time.zone.now.at_beginning_of_quarter.to_date }
    name { product.name }
    quantity { 100 }
    gross_revenue_amount { quantity * product.list_price }
    # 25% after 3% CC transaction fees
    net_revenue_amount { gross_revenue_amount * 0.97 * 0.25 }
  end
end
