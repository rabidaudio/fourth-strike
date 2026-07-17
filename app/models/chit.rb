# frozen_string_literal: true

# A chit (aka dues) is a single atomic unit of money due to a payee.
# This could be their royalty proportion for a Sale, or a service rendered.
# It has an earnings amount in USD (a numeric, so that fractional cents can be stored),
# and a date the money was earned.
# This table is "de-normalized" (meaning it duplicates data from elsewhere
# in the database) for query performance. Every time a sale or rendered service
# is created or destroyed, or splits change, the chits MUST be updated.
# This drastically improves the query performance for pages, quickly calculating
# in the database how much is owed to a particular person.
# == Schema Information
#
# Table name: chits
#
#  id                  :integer          not null, primary key
#  earned_at           :datetime         not null
#  earnings_usd        :decimal(, )      not null
#  product_type        :string
#  sale_type           :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  payee_id            :integer          not null
#  product_id          :integer
#  rendered_service_id :integer
#  sale_id             :integer
#
# Indexes
#
#  idx_on_sale_type_sale_id_rendered_service_id_payee__fd3ebe7ce7  (sale_type,sale_id,rendered_service_id,payee_id) UNIQUE
#  index_chits_on_earned_at                                        (earned_at)
#  index_chits_on_payee_id                                         (payee_id)
#  index_chits_on_product                                          (product_type,product_id)
#  index_chits_on_rendered_service_id                              (rendered_service_id)
#  index_chits_on_sale                                             (sale_type,sale_id)
#
class Chit < ApplicationRecord
  belongs_to :product, polymorphic: true, optional: true
  belongs_to :sale, polymorphic: true, optional: true
  belongs_to :rendered_service, optional: true
  belongs_to :payee

  validate :ensure_for_sale_or_service

  scope :for_service, -> { where.not(rendered_service: nil) }
  scope :for_track_sales, -> { where(product_type: 'Track') }
  scope :for_album_sales, -> { where(product_type: 'Album') }
  scope :for_merch_sales, -> { where(product_type: 'Merch') }
  scope :for_payee, ->(payee) { where(payee_id: payee) }

  def self.sum_earnings
    (current_scope || all).sum(:earnings_usd).to_money('USD')
  end

  def self.recompute_for_sale!(sale)
    ChitComputer.recompute_for_sale!(sale)
  end

  def self.recompute_for_service_rendered!(service_rendered)
    ChitComputer.recompute_for_service_rendered!(service_rendered)
  end

  def self.recompute_for_product_splits!(product)
    ChitComputer.recompute_for_product_splits!(product)
  end

  def self.recompute_all!
    ChitComputer.recompute_all!
  end

  private

  def ensure_for_sale_or_service
    if rendered_service.present?
      errors.add(:rendered_service, 'cannot be set with a sale') if product.present? || sale.present?
    elsif sale.present?
      errors.add(:product, 'must be set if sale is set') if product.blank?
      errors.add(:product, 'must match sale') if sale.product != product
    else
      errors.add(:sale, 'or service rendered must be set')
    end
  end
end
