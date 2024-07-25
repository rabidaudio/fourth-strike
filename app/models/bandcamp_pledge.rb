# frozen_string_literal: true

# == Schema Information
#
# Table name: bandcamp_pledges
#
#  id                     :integer          not null, primary key
#  level                  :string
#  pledge_amount_cents    :integer          default(0), not null
#  pledge_amount_currency :string           default("USD"), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  bandcamp_pledge_id     :string           not null
#
# Indexes
#
#  index_bandcamp_pledges_on_bandcamp_pledge_id  (bandcamp_pledge_id) UNIQUE
#

# Bandcamp has a "Campaign" feature which is essentially like a Kickstarter.
# Unfortunately they don't track them like sales; they come in a separate report.
# TODO: finish building when we can calculate the costs of production.
class BandcampPledge < ApplicationRecord
  include Sale

  monetize :subtotal_amount_cents
end
