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

  belongs_to :merch_fulfillment, optional: true

  scope :unfulfilled_merch, -> { where(product_type: 'Merch').where(refunded: false, merch_fulfillment_id: nil) }
  # If a merch order hasn't been fulfilled, don't include it in money to be paid in royalties, since
  # we'll need those funds to fulfill the order
  scope :payable, -> { where.not(id: BandcampSale.unfulfilled_merch) }

  scope :digital, -> { where.not(product_type: 'Merch') }
  scope :merch, -> { where(product_type: 'Merch') }

  scope :sales_by_month, lambda {
    group(
      "date(purchased_at, 'start of month')",
      "CASE WHEN product_type = 'Merch' THEN 'physical' ELSE 'digital' END"
    ).sum_monetized(:net_revenue_amount)
      .group_by { |(date, _type), _v| date }
      .transform_values(&:to_h)
      .transform_values { |h| h.transform_keys(&:last) }
  }

  # Require sales to be in the operating currency
  validates :subtotal_amount_currency, :net_revenue_amount_currency, inclusion: { in: Money.default_currency.iso_code }

  def refunded?
    refunded
  end

  def overdue?
    return false unless product_type == 'Merch'
    return false if merch_fulfillment.present?

    purchased_at < 1.week.ago
  end
end
