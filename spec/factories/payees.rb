# frozen_string_literal: true

# == Schema Information
#
# Table name: payees
#
#  id             :integer          not null, primary key
#  paypal_account :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_payees_on_paypal_account  (paypal_account) UNIQUE
#
FactoryBot.define do
  factory :payee do
    paypal_account { Faker::Internet.email }
  end
end
