# frozen_string_literal: true

# == Schema Information
#
# Table name: payouts
#
#  id                    :integer          not null, primary key
#  amount_cents          :integer          default(0), not null
#  amount_currency       :string           default("USD"), not null
#  paid_at               :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  payee_id              :integer          not null
#  paypal_transaction_id :string
#
# Indexes
#
#  index_payouts_on_payee_id               (payee_id)
#  index_payouts_on_paypal_transaction_id  (paypal_transaction_id) UNIQUE
#
# Foreign Keys
#
#  payee_id  (payee_id => payees.id)
#

# A payout is an instance when the organization made a payment to a Payee.
class Payout < ApplicationRecord
  belongs_to :payee

  monetize :amount_cents

  # Require all payouts to be in system currency
  validates :amount_currency, inclusion: { in: [MoneyRails.default_currency.iso_code] }

  # aggregation for computing the total amount of the queried payouts
  def self.sum_amount
    return 0.to_money if current_scope.empty?

    totals = current_scope.group(:amount_currency).sum('amount_cents')
    raise StandardError, 'Cannot sum payouts in differenct currencies' if totals.size > 1

    currency, cents = totals.to_a.first
    Money.new(cents, currency)
  end
end
