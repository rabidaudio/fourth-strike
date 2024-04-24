# frozen_string_literal: true

# A product that has a weighted royalty distribution attached.
module Splittable
  extend ActiveSupport::Concern

  included do |base|
    base.has_many :splits, as: :splittable, dependent: :destroy

    # Too many split objects can create some performance problems, since
    # computations happen in memory rather than in the database. So set
    # a limit to an arbitrary but sufficiently high amount.
    # Can be increased if needed.
    base.validates :splits, length: { maximum: 50 }
  end

  # Returns a hash mapping payees to a fractional split of funds (0,1]
  def weighted_distribution
    parts = splits.includes(:payee).each_with_object({}) do |split, hash|
      hash[split.payee] ||= 0
      hash[split.payee] += split.value
    end
    sum = parts.values.sum.to_f
    parts.transform_values { |v| v / sum }
  end

  # Given an amount of money to be distributed, weight it across the distribution.
  # Returns a hash mapping payees to Money objects.
  def payout_amounts(money)
    weighted_distribution.transform_values { |weight| weight * money }
  end
end
