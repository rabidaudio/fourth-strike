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
#  index_bandcamp_sales_on_bandcamp_transaction_id_and_item_url  (bandcamp_transaction_id,item_url) UNIQUE
#  index_bandcamp_sales_on_item_url                              (item_url)
#  index_bandcamp_sales_on_paypal_transaction_id                 (paypal_transaction_id)
#  index_bandcamp_sales_on_product                               (product_type,product_id)
#  index_bandcamp_sales_on_upc                                   (upc)
#

# Revenue received from Bandcamp. This can come from digital sales of albums
# or individual tracks, or sales of physical merch.
# Subtotal amount is the amount the customer paid (including additional contribution, shipping and tax if applicable).
# Net Revenue amount is the amount received after transaction fees, shipping, and Bandcamp's cut.
# If the item is a merch item, option contains variant information for the product, such as t-shirt size.
# Two sales can have the same bandcamp_transaction_id, if the user bought multiple items at the same time.
class BandcampSale < ApplicationRecord
  include Sale

  monetize :subtotal_amount_cents
  monetize :net_revenue_amount_cents

  has_one :merch_fulfillment, required: false, dependent: :restrict_with_exception

  scope :unfulfilled_merch, -> { where(product_type: 'Merch').where.missing(:merch_fulfillment) }

  # Require sales to be in the operating currency
  validates :subtotal_amount_currency, :net_revenue_amount_currency, inclusion: { in: Money.default_currency.iso_code }

  def payout_amounts
    product.payout_amounts(net_revenue_amount)
  end

  def overdue?
    return false unless product_type == 'Merch'
    return false if merch_fulfillment.present?

    purchased_at < 1.week.ago
  end
end
