# frozen_string_literal: true

# == Schema Information
#
# Table name: rendered_services
#
#  id                    :integer          not null, primary key
#  artist_name           :string
#  compensation_cents    :integer          default(0), not null
#  compensation_currency :string           default("USD"), not null
#  description           :text             not null
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

# This model tracks services rendered, for example: labor for the organization,
# mastering of an album, or one-time fees for the album artwork.
# These can be hourly (which are paid at `hourly_rate`), or a fixed amount.
# These are payed to Payees along with royalties.
# If there is an album associated with it, these fees will come off the top of
# album income before paying out royalties.
class RenderedService < ApplicationRecord
  include MonitizedSum
  self.inheritance_column = '_type'

  belongs_to :payee
  belongs_to :album, optional: true

  monetize :compensation_cents
  strip_attributes only: [:description]

  enum type: {
    fixed: 1,
    hourly: 2
  }

  validates :compensation_cents, numericality: { greater_than: 0 }
  validates :compensation_currency, inclusion: { in: Money.default_currency.iso_code }
  validates :hours, numericality: { greater_than: 0, allow_nil: true }
  validates :hours, presence: true, if: :hourly?
  validates :hours, absence: true, if: :fixed?
  validates :artist_name, inclusion: { in: Album.distinct.pluck(:artist_name), allow_nil: true }
  validate :ensure_payee_not_a_charity

  before_validation do |service|
    service.compensation = service.hours * RenderedService.hourly_rate if service.hourly? && service.compensation.zero?
  end

  def self.hourly_rate
    Rails.application.config.app_config[:services_rendered][:hourly_rate].to_money('USD')
  end

  protected

  def ensure_payee_not_a_charity
    return if payee.blank?

    errors.add(:payee, 'cannot be a charity') if payee.charity?
  end
end
