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
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  payee_id       :integer
#
# Indexes
#
#  index_artists_on_discord_handle  (discord_handle) UNIQUE
#  index_artists_on_payee_id        (payee_id)
#
# Foreign Keys
#
#  payee_id  (payee_id => payees.id)
#
FactoryBot.define do
  factory :artist do
    transient do
      paypal_account { Faker::Internet.email }
    end

    payee { association(:payee, paypal_account: paypal_account) if paypal_account }

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

    bio { Faker::Markdown.sandwich }
    contact_info { nil }
    discord_handle { Faker::Internet.username }
  end
end
