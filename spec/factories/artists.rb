# frozen_string_literal: true

# == Schema Information
#
# Table name: artists
#
#  id             :integer          not null, primary key
#  aliases        :text             not null
#  bio            :text
#  contact_info   :string
#  credit         :string
#  discord_handle :string           not null
#  name           :string           not null
#  paypal_account :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_artists_on_discord_handle  (discord_handle) UNIQUE
#
FactoryBot.define do
  factory :artist do
    name do
      [
        Faker::Name.first_name.downcase,
        Faker::Name.name,
        Faker::Internet.username
      ].sample
    end
    credit { "#{Faker::Music.band} ( #{Faker::Internet.username}.bandcamp.com )" }
    aliases do
      (0..2).to_a.sample.times.map { Faker::Name.first_name }
    end
    paypal_account { Faker::Internet.email }
    bio do
      [
        Faker::Lorem.paragraph,
        "Check out my band at #{Faker::Internet.username}.bandcamp.com"
      ].join("\n\n")
    end
    contact_info { nil }
    discord_handle { Faker::Internet.username }
  end
end
