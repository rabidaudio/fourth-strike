# frozen_string_literal: true

# == Schema Information
#
# Table name: splits
#
#  id              :integer          not null, primary key
#  splittable_type :string           not null
#  value           :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  payee_id        :integer          not null
#  splittable_id   :integer          not null
#
# Indexes
#
#  index_splits_on_payee_id    (payee_id)
#  index_splits_on_splittable  (splittable_type,splittable_id)
#
# Foreign Keys
#
#  payee_id  (payee_id => payees.id)
#
FactoryBot.define do
  factory :split do
    payee
    splittable { association(:album) }
    value { 1 }
  end
end
