# frozen_string_literal: true

# ChitComputer denormalizes sales and services into chits.
# These methods will need to be called when the dependant data is changed
# to ensure that balances are reflected correctly.
class ChitComputer
  def initialize
    @removals = []
    @chits = []
  end

  def self.recompute_for_sale!(sale)
    ChitComputer.new.compute_sale(sale).upsert!
  end

  def self.recompute_for_service_rendered!(service_rendered)
    ChitComputer.new.compute_service_rendered(service_rendered).upsert!
  end

  def self.recompute_for_product_splits!(product)
    ChitComputer.new.compute_product_splits(product).upsert!
  end

  def self.recompute_for_payee!(payee)
    ChitComputer.new.compute_payee(payee).upsert!
  end

  def self.recompute_all!
    ChitComputer.new.all.upsert!
  end

  def compute_sale(sale)
    remove(Chit.where(sale: sale))
    income = sale.distributable_income
    push(
      sale: sale,
      product: sale.product,
      payee: org,
      earned_at: sale.sold_at,
      earnings_usd: income.total_org_income.to_f
    )
    if sale.product.splits.empty?
      push(
        sale: sale,
        product: sale.product,
        payee: nil, # indicates unassigned
        earned_at: sale.sold_at,
        earnings_usd: income.total_earned_royalties.to_f
      )
    else
      # for each split
      income.owed_royalties.each do |payee, money|
        next if payee.org?

        push(
          sale: sale,
          product: sale.product,
          payee: payee,
          earned_at: sale.sold_at,
          earnings_usd: money.to_f
        )
      end
    end
    self
  end

  def compute_service_rendered(service_rendered)
    remove(Chit.where(rendered_service: service_rendered))
    push(
      rendered_service: service_rendered,
      payee: service_rendered.payee,
      earned_at: service_rendered.rendered_at,
      earnings_usd: service_rendered.compensation.to_f
    )
    self
  end

  def compute_product_splits(product)
    remove(Chit.where(product: product))
    product.each_sale do |sale|
      compute_sale(sale)
    end
    self
  end

  def compute_payee(payee)
    remove(Chit.where(payee: payee))
    payee.splits.find_each do |split|
      compute_product_splits(split.product)
    end
  end

  def all
    remove(Chit.all)
    @all_deleted = true
    RenderedService.find_each { |rs| compute_service_rendered(rs) }
    Product.each_product { |p| compute_product_splits(p) }
    self
  end

  def upsert!
    ActiveRecord::Base.transaction do
      Rails.logger.info('removing chits')
      @removals.each(&:delete_all)
      Rails.logger.info("upsert-ing #{@chits.count} chits")
      # rubocop:disable Rails/SkipsModelValidations
      Chit.upsert_all(@chits, unique_by: [:sale_type, :sale_id, :rendered_service_id, :payee_id])
      # rubocop:enable Rails/SkipsModelValidations
    end
  end

  def org
    @org ||= Payee.org
  end

  def remove(query)
    return if @all_deleted

    @removals.push(query)
  end

  def push(**params)
    @chits.push({
                  sale_type: params[:sale]&.class&.name,
                  sale_id: params[:sale]&.id,
                  product_type: params[:product]&.class&.name,
                  product_id: params[:product]&.id,
                  payee_id: params[:payee]&.id,
                  rendered_service_id: params[:rendered_service]&.id,
                  earned_at: params[:earned_at],
                  earnings_usd: params[:earnings_usd]
                })
  end
end
