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
class Iam8bitSale < ApplicationRecord
  include Sale

  monetize :gross_revenue_amount_cents
  monetize :net_revenue_amount_cents

  validates :gross_revenue_amount_currency, :net_revenue_amount_currency,
            inclusion: { in: Money.default_currency.iso_code }
  # Iam8bit only sells merch items
  validates :product_type, inclusion: { in: ['Merch'] }

  validate :ensure_period_is_a_quarter

  def quarter
    [{ 1 => 'Q1', 4 => 'Q2', 7 => 'Q3', 10 => 'Q4' }[period.month], period.year].join(' ')
  end

  private

  def ensure_period_is_a_quarter
    errors.add(:period, 'must be a quarter') unless period == period.at_beginning_of_quarter
  end
end
