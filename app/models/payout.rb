# frozen_string_literal: true

# == Schema Information
#
# Table name: payouts
#
#  id                    :integer          not null, primary key
#  amount_cents          :integer          default(0), not null
#  amount_currency       :string           default("USD"), not null
#  note                  :text
#  paid_at               :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  payee_id              :integer          not null
#  paypal_transaction_id :string
#
# Indexes
#
#  index_payouts_on_payee_id  (payee_id)
#
# Foreign Keys
#
#  payee_id  (payee_id => payees.id)
#

# A payout is an instance when the organization made a payment to a Payee.
class Payout < ApplicationRecord
  include MonitizedSum

  belongs_to :payee

  has_one :internal_merch_order, required: false, dependent: :destroy

  monetize :amount_cents

  # Require all payouts to be in system currency
  validates :amount_currency, inclusion: { in: [MoneyRails.default_currency.iso_code] }

  after_save do |payout|
    CalculatorCache::Manager.recompute_for_payout!(payout)
  end

  after_destroy do |payout|
    CalculatorCache::Manager.recompute_for_payout!(payout)
  end

  def self.payout_at
    Rails.application.config.app_config[:payout_at].to_money
  end
end
