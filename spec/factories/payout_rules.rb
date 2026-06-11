# frozen_string_literal: true

FactoryBot.define do
  factory :payout_rule do
    source_payee { association(:payee) }
    target_payee { association(:payee) }
  end
end
