# frozen_string_literal: true

# == Schema Information
#
# Table name: splits
#
#  id           :integer          not null, primary key
#  product_type :string           not null
#  value        :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  payee_id     :integer          not null
#  product_id   :integer          not null
#
# Indexes
#
#  index_splits_on_payee_id  (payee_id)
#  index_splits_on_product   (product_type,product_id)
#
# Foreign Keys
#
#  payee_id  (payee_id => payees.id)
#

# A Split is a proportional distribution of royalties for a splittable
# product (Album, Track, or Merch). Typically splits are allocated only
# to major writing credits, not to additional credits such as extra
# performers. Album splits are generally evenly divided across any
# contributors rather than proportional to the number of contributions.
# Value is an integer number of shares that payee receives. For example:
# Alice=2, Bob=1, Chad=1 then Alice gets 50%, and Bob and Chad each get 25%.
# See Product for some logic that is applicable to all products.
class Split < ApplicationRecord
  belongs_to :payee
  belongs_to :product, polymorphic: true

  validates :value, numericality: { greater_than_or_equal_to: 1 }

  def to_percentage_string
    decimal = value.to_f / product.splits.sum(:value)
    "#{(decimal * 100).round(2)}%"
  end
end
