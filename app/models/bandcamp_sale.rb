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
#  product_type                :string           not null
#  purchased_at                :datetime         not null
#  quantity                    :integer          not null
#  sku                         :string
#  subtotal_amount_cents       :integer          default(0), not null
#  subtotal_amount_currency    :string           default("USD"), not null
#  upc                         :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  bandcamp_transaction_id     :string
#  paypal_transaction_id       :string
#  product_id                  :integer          not null
#
# Indexes
#
#  index_bandcamp_sales_on_bandcamp_transaction_id  (bandcamp_transaction_id) UNIQUE
#  index_bandcamp_sales_on_item_url                 (item_url)
#  index_bandcamp_sales_on_paypal_transaction_id    (paypal_transaction_id)
#  index_bandcamp_sales_on_product                  (product_type,product_id)
#  index_bandcamp_sales_on_upc                      (upc)
#

# Revenue received from Bandcamp. This can come from digital sales of albums
# or individual tracks, or sales of physical merch.
# Subtotal amount is the amount the customer paid (including shipping and tax if applicable).
# Net Revenue amount is the amount received after transaction fees and Bandcamp's cut.
class BandcampSale < ApplicationRecord
  include MonitizedSum

  monetize :subtotal_amount_cents
  monetize :net_revenue_amount_cents

  # Require sales to be in the operating currency
  validates :subtotal_amount_currency, :net_revenue_amount_currency, inclusion: { in: Money.default_currency.iso_code }

  belongs_to :product, polymorphic: true
  has_many :splits,
           primary_key: [:product_type, :product_id],
           query_constraints: [:product_type, :product_id],
           dependent: nil
  has_many :payees, through: :splits

  def payout_amounts
    product.payout_amounts(net_revenue_amount)
  end
end
