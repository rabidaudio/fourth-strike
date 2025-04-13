# frozen_string_literal: true

# Compute the total income and debts for the org for a given time period.
# Works without all splits being calculated (although will over-estimate
# artist dues if some artists have donated their royalties), but cannot
# function without all merch fulfilments being tracked.
class ProfitAndLossCalculator
  attr_accessor :time_range

  def initialize(time_range = 1.year.ago...Time.zone.now)
    @time_range = time_range

    # if BandcampSale.where(purchased_at: time_range).unfulfilled_merch.present?
    #   raise StandardError, 'Unable to compute profit and loss as merch shipments for this period have not been input'
    # end
  end

  def digital_gross_revenue
    sales_royalties.filter(&:album?).sum(&:gross_revenue)
  end

  def digital_net_revenue
    sales_royalties.filter(&:album?).sum(&:net_revenue)
  end

  def streaming_gross_revenue
    sales_royalties.filter(&:track?).sum(&:gross_revenue)
  end

  def streaming_net_revenue
    sales_royalties.filter(&:track?).sum(&:net_revenue)
  end

  def merch_gross_revenue
    sales_royalties.filter(&:merch?).sum(&:gross_revenue)
  end

  def merch_net_revenue
    sales_royalties.filter(&:merch?).sum(&:net_revenue)
  end

  def charity_dues
    distributable_income.sum(&:charity_royalties)
  end

  def charities_paid
    charity_payouts.sum_monetized(:amount)
  end

  def charity_outstanding
    charity_dues - charities_paid
  end

  def services_rendered_owed
    rendered_services.sum_monetized(:compensation)
  end

  def artist_royalties_earned
    distributable_income.sum(&:total_artist_royalties)
  end

  def artist_royalties_and_services_owed
    services_rendered_owed + artist_royalties_earned
  end

  def artist_royalties_and_services_paid
    artist_payouts.sum_monetized(:amount)
  end

  def artist_outstanding
    artist_royalties_earned + services_rendered_owed - artist_royalties_and_services_paid
  end

  def organization_profit
    distributable_income.sum(&:total_org_income)
  end

  private

  def bandcamp_sales
    BandcampSale.where(purchased_at: time_range).distinct.pluck(:product_type, :product_id)
  end

  def distrokid_sales
    DistrokidSale.where(sale_period: time_range).distinct.pluck(:product_type, :product_id)
  end

  def bandcamp_pledges
    BandcampPledge.where(funded_at: time_range).distinct.pluck(:product_type, :product_id)
  end

  def iam8bit_sales
    Iam8bitSale.where(period: time_range).distinct.pluck(:product_type, :product_id)
  end

  def patreon_sales
    PatreonSale.where(period: time_range).distinct.pluck(:product_type, :product_id)
  end

  def sold_products
    @sold_products ||= begin
      # find all products sold in the period
      @sold_products = bandcamp_sales + distrokid_sales + bandcamp_pledges + iam8bit_sales + patreon_sales
      # flatten to a mapping of { type => [ids] }
      @sold_products = @sold_products.sort.uniq.group_by(&:first).transform_values { |v| v.map(&:last) }
      # query for all products and get their royalty calculators
      @sold_products = @sold_products.map { |type, ids| type.constantize.where(id: ids).to_a }.flatten
    end
  end

  def sales_royalties
    @sales_royalties ||= sold_products.map { |p| RoyaltyCalculator.new(p, from: time_range.begin, to: time_range.end) }
  end

  def distributable_income
    sales_royalties.map(&:distributable_income)
  end

  def rendered_services
    @rendered_services ||= RenderedService.where(rendered_at: time_range)
  end

  def charity_payouts
    @charity_payouts ||= Payout.joins(:payee).merge(Payee.charity).where(paid_at: time_range)
  end

  def artist_payouts
    @artist_payouts ||= Payout.joins(:payee).merge(Payee.artist).where(paid_at: time_range)
  end
end
