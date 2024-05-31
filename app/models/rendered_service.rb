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
#  hours                 :decimal(, )
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
  self.inheritance_column = '_type'

  belongs_to :payee
  belongs_to :album, optional: true

  monetize :compensation_cents

  enum type: {
    fixed: 1,
    hourly: 2
  }

  validates :compensation_cents, numericality: { greater_than: 0 }
  validates :compensation_currency, inclusion: { in: Money.default_currency.iso_code }
  validates :hours, numericality: { greater_than: 0, allow_nil: true }
  validates :hours, presence: true, if: :hourly?
  validates :hours, absence: true, if: :fixed?
  validate :validate_hours_multiple_of_fifteen_minutes
  validates :artist_name, inclusion: { in: Album.distinct.pluck(:artist_name), allow_nil: true }

  before_validation do |service|
    service.compensation = service.hours * RenderedService.hourly_rate if service.hourly? && service.compensation.zero?
  end

  def self.hourly_rate
    Rails.application.config.app_config[:services_rendered][:hourly_rate].to_money('USD')
  end

  protected

  def validate_hours_multiple_of_fifteen_minutes
    return if hours.blank?

    errors.add(:hours, 'must be a multiple of 15 minutes') unless ((hours.to_f * 100) % 25).zero?
  end
end
