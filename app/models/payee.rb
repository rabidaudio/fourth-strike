# frozen_string_literal: true

# == Schema Information
#
# Table name: payees
#
#  id             :integer          not null, primary key
#  paypal_account :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_payees_on_paypal_account  (paypal_account) UNIQUE
#

# A recipient of a payout. Typically belongs to an artist but not always
# (for example: charities, service providers, etc).
# Paypal account is the email address of the paypal account they wish to be
# paid to.
class Payee < ApplicationRecord
  has_many :artists, dependent: :restrict_with_exception
  has_many :payouts, dependent: :restrict_with_exception

  def paid_out(since: nil, before: nil)
    q = payouts
    q = q.where('paid_at >= ?', since) if since.present?
    q = q.where('paid_at < ?', before) if before.present?
    q.sum_amount
  end
end
