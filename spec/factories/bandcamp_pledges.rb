# frozen_string_literal: true

# == Schema Information
#
# Table name: bandcamp_pledges
#
#  id                          :integer          not null, primary key
#  funded_at                   :datetime         not null
#  level                       :string
#  net_revenue_amount_cents    :integer          default(0), not null
#  net_revenue_amount_currency :string           default("USD"), not null
#  pledge_amount_cents         :integer          default(0), not null
#  pledge_amount_currency      :string           default("USD"), not null
#  product_type                :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  bandcamp_pledge_id          :string           not null
#  product_id                  :integer
#
# Indexes
#
#  index_bandcamp_pledges_on_bandcamp_pledge_id  (bandcamp_pledge_id) UNIQUE
#  index_bandcamp_pledges_on_product             (product_type,product_id)
#
FactoryBot.define do
  factory :bandcamp_pledge do
    bandcamp_pledge_id { Faker::Number.number(digits: 5).to_s }

    product { association(:merch, :vinyl) }

    transient do
      level_idx { [0, 1, 2, 3].sample }
    end

    level do
      [
        '12″ Vinyl Record + Digital Album',
        'Record + Rainbow Sticker Pack',
        'Record + Rainbow Sticker Pack + Special Thanks',
        'Record + Rainbow Sticker Pack + Extra Special Thanks'
      ][level_idx]
    end

    pledge_amount { [25, 35, 55, 100][level_idx].to_money('USD') }
  end
end
