# frozen_string_literal: true

# == Schema Information
#
# Table name: splits
#
#  id           :integer          not null, primary key
#  product_type :string           not null
#  value        :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  payee_id     :integer          not null
#  product_id   :integer          not null
#
# Indexes
#
#  index_splits_on_payee_id  (payee_id)
#  index_splits_on_product   (product_type,product_id)
#
# Foreign Keys
#
#  payee_id  (payee_id => payees.id)
#
FactoryBot.define do
  factory :split do
    payee
    product { association(:album) }
    value { 1 }
  end
end
