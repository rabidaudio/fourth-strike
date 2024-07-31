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

# Bandcamp has a "Campaign" feature which is essentially like a Kickstarter.
# Unfortunately they don't track them like sales; they come in a separate report.
class BandcampPledge < ApplicationRecord
  include Sale

  monetize :pledge_amount_cents, :net_revenue_amount_cents
end
