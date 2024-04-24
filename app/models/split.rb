# frozen_string_literal: true

# == Schema Information
#
# Table name: splits
#
#  id              :integer          not null, primary key
#  splittable_type :string           not null
#  value           :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  payee_id        :integer          not null
#  splittable_id   :integer          not null
#
# Indexes
#
#  index_splits_on_payee_id    (payee_id)
#  index_splits_on_splittable  (splittable_type,splittable_id)
#
# Foreign Keys
#
#  payee_id  (payee_id => payees.id)
#

# A Split is a proportional distribution of royalties for a splittable
# item (Album, Track, or Merch). Typically splits are allocated only
# to major writing credits, not to additional credits such as extra
# performers. Album splits are generally evenly divided across any
# contributors rather than proportional to the number of contributions.
# Value is an integer number of shares that payee receives. For example:
# Alice=2, Bob=1, Chad=1 then Alice gets 50%, and Bob and Chad each get 25%.
# See Splittable for some logic that is applicable to all splittable products.
class Split < ApplicationRecord
  belongs_to :payee
  belongs_to :splittable, polymorphic: true

  validates :value, numericality: { greater_than_or_equal_to: 1 }
end
