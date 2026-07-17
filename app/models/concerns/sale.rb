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
    base.has_many :chits, as: :sale, dependent: :destroy

    base.after_create do |sale|
      Chit.recompute_for_sale!(sale)
    end

    base.after_update do |sale|
      Chit.recompute_for_sale!(sale)
    end
  end

  def distributable_income
    income = net_revenue_amount
    income -= merch_fulfillment.production_cost if respond_to?(:merch_fulfillment) && merch_fulfillment.present?
    income = 0.to_money if respond_to?(:refunded) && refunded?
    RoyaltyCalculator::RoyaltyMoney.new(income, product)
  end

  def sold_at
    case self.class.name
    when 'BandcampPledge' then funded_at
    when 'BandcampSale' then purchased_at
    when 'DistrokidSale' then reported_at
    when 'Iam8bitSale', 'PatreonSale' then period
    end
  end
end
