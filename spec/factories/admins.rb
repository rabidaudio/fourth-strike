# frozen_string_literal: true

# == Schema Information
#
# Table name: admins
#
#  id             :integer          not null, primary key
#  discord_handle :string           not null
#  granted_at     :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_admins_on_discord_handle  (discord_handle) UNIQUE
#
FactoryBot.define do
  factory :admin do
    discord_handle { [Faker::Internet.username, Faker::Number.number(digits: 4)].join('_') }
    granted_at { Time.zone.now }
  end
end
