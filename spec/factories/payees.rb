# frozen_string_literal: true

# == Schema Information
#
# Table name: payees
#
#  id             :integer          not null, primary key
#  fsn            :string           not null
#  name           :string           not null
#  paypal_account :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_payees_on_fsn             (fsn) UNIQUE
#  index_payees_on_paypal_account  (paypal_account) UNIQUE
#
FactoryBot.define do
  sequence :fsn do |n|
    Payee.build_fsn(n)
  end

  factory :payee do
    fsn
    name { Faker::Name.name }
    paypal_account { Faker::Internet.email }
  end
end
