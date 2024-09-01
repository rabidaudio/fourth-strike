# frozen_string_literal: true

# == Schema Information
#
# Table name: payees
#
#  id                     :integer          not null, primary key
#  fsn                    :string           not null
#  is_charity             :boolean          default(FALSE), not null
#  name                   :string           not null
#  opted_out_of_royalties :boolean          default(FALSE), not null
#  paypal_account         :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
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

  has_many :splits, dependent: :destroy
  has_many :rendered_services, dependent: :restrict_with_exception

  validates :fsn, format: { with: /\AFS-[0-9]{3}\z/, message: 'should match the form FS-XXX' }

  before_save do |payee|
    payee.fsn ||= Payee.next_fsn
  end

  scope :missing_payment_info, -> { where(paypal_account: nil, opted_out_of_royalties: false) }

  scope :search, lambda { |keyword|
    search_value = "%#{keyword.strip.downcase}%"
    left_outer_joins(:artists).where(
      # TODO: lazy json searching, treating as string
      'lower(payees.fsn) like ? OR ' \
      'lower(payees.name) like ? OR lower(payees.paypal_account) like ? ' \
      'OR lower(artists.name) like ? OR lower(artists.aliases) like ? ' \
      'OR lower(artists.contact_info) like ?',
      *6.times.map { search_value }
    )
  }

  def self.due_for_payout
    (current_scope || all).find_each.select(&:due_for_payout?)
  end

  def albums
    Album.joins(:splits).where(splits: { payee: self }).distinct
  end

  def tracks
    Track.joins(:splits).where(splits: { payee: self }).distinct
  end

  def merch
    Merch.joins(:splits).where(splits: { payee: self }).distinct
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

  def charity?
    is_charity
  end

  def opted_out_of_royalties?
    opted_out_of_royalties
  end

  def due_for_payout?
    balance > Payout.payout_at
  end

  def royalties_owed(**)
    PayoutCalculator.new(self, **).for_royalties
  end

  def services_rendered_owed(**)
    PayoutCalculator.new(self, **).for_services_rendered
  end

  def total_owed(**)
    PayoutCalculator.new(self, **).total_owed
  end

  def paid_out(**)
    PayoutCalculator.new(self, **).total_paid
  end

  def balance(**)
    total_owed(**) - paid_out(**)
  end
end
