# frozen_string_literal: true

# == Schema Information
#
# Table name: payees
#
#  id             :integer          not null, primary key
#  fsn            :string           not null
#  name           :string           not null
#  paypal_account :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_payees_on_fsn             (fsn) UNIQUE
#  index_payees_on_paypal_account  (paypal_account)
#

# A recipient of a payout. Typically belongs to an artist but not always
# (for example: charities, service providers, etc).
# Paypal account is the email address of the paypal account they wish to be
# paid to.
# All payees are given an fsn (a unique Fourth Strike ID), like FS-001.
# FS-000 is reserved for the organization.
class Payee < ApplicationRecord
  has_many :artists, dependent: :restrict_with_exception
  has_many :payouts, dependent: :restrict_with_exception

  validates :fsn, format: { with: /\AFS-[0-9]{3}\z/, message: 'should match the form FS-XXX' }

  before_save do |payee|
    payee.fsn ||= Payee.next_fsn
  end

  def self.next_fsn
    last_fsn = Payee.maximum(:fsn) || 'FS-000'
    num = last_fsn.delete_prefix('FS-').to_i
    build_fsn(num + 1)
  end

  def self.build_fsn(number)
    "FS-#{number.to_s.rjust(3, '0')}"
  end

  def artist
    artists.first if artists.count == 1
  end

  def paid_out(since: nil, before: nil)
    q = payouts
    q = q.where('paid_at >= ?', since) if since.present?
    q = q.where('paid_at < ?', before) if before.present?
    q.sum_monetized(:amount)
  end
end
