# frozen_string_literal: true

# A sale through some channel for some Product.
module Sale
  extend ActiveSupport::Concern

  included do |base|
    base.include MonitizedSum

    base.belongs_to :product, polymorphic: true
    base.has_many :splits,
                  primary_key: [:product_type, :product_id],
                  query_constraints: [:product_type, :product_id],
                  dependent: nil
    base.has_many :payees, through: :splits

    base.after_save do |sale|
      CalculatorCache::Manager.recompute_for_sale!(sale)
    end

    base.after_destroy do |sale|
      CalculatorCache::Manager.recompute_for_sale!(sale)
    end
  end
end
