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
FactoryBot.define do
  factory :payout do
    payee
    paid_at { Time.zone.now }
    paypal_transaction_id { Faker::Crypto.md5 }
    amount { 4.99.to_money }
  end
end
