# frozen_string_literal: true

# A sale through some channel for some Product.
module Sale
  extend ActiveSupport::Concern

  included do |base|
    base.include MonetizedSum

    base.belongs_to :product, polymorphic: true
    base.has_many :splits, # rubocop:disable Rails/InverseOf
                  primary_key: [:product_type, :product_id],
                  foreign_key: [:product_type, :product_id],
                  dependent: nil
    base.has_many :payees, through: :splits
  end
end
