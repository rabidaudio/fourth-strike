# frozen_string_literal: true

# == Schema Information
#
# Table name: rendered_services
#
#  id                    :integer          not null, primary key
#  artist_name           :string
#  compensation_cents    :integer          default(0), not null
#  compensation_currency :string           default("USD"), not null
#  description           :text
#  hours                 :decimal(6, 2)
#  rendered_at           :date
#  type                  :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  album_id              :integer
#  payee_id              :integer          not null
#
# Indexes
#
#  index_rendered_services_on_album_id  (album_id)
#  index_rendered_services_on_payee_id  (payee_id)
#
# Foreign Keys
#
#  album_id  (album_id => albums.id)
#  payee_id  (payee_id => payees.id)
#
FactoryBot.define do
  factory :rendered_service do
    payee
    rendered_at { Time.zone.today }
    type { :hourly }
    hours { 0.5 }
    description { album.present? ? "Mastering for #{album.name}" : 'Merchandise fulfillment' }
    artist_name { album&.artist_name }
    album { nil }

    trait :hourly do
      type { :hourly }
    end

    trait :fixed do
      type { :fixed }
      hours { nil }
      compensation { 50.to_money }
      description { 'Art assets' }
    end

    trait :for_album do
      album
    end
  end
end
