# frozen_string_literal: true

# This class computes the amount owed to contributors for a single product (optionally over a time period).
# All methods return Money inless otherwise indicated.
# TODO: this does a lot of computing in ruby. Doing in the database would be better for performance,
# but we've got small enough data that I'm banking that the performance shouldn't be too bad.
# If it does get really bad, we could create a caching system to recompute
class RoyaltyCalculator
  def initialize(product, from: Time.zone.at(0), to: Time.zone.now)
    @product = product
    @start_at = from
    @end_at = to
  end

  # One time expenses for a project. For example: album art, mastering, etc.
  # These are taken out before any royalties are paid.
  def upfront_costs
    # TODO: implement on top of services_rendered
    0.to_money
  end

  # Revenue from bandcamp digial sales, excluding Bandcamp and payment processor fees
  def bandcamp_revenue
    bandcamp_sales.sum_monetized(:net_revenue_amount)
  end

  # Distrokid streaming revenue
  def distrokid_revenue
    # return 0.to_money if @product.is_a?(Merch)

    0.to_money # TODO
  end

  # Bandcamp merchandise revenue (how much came in)
  def merchandise_revenue
    # return 0.to_money unless @product.is_a?(Merch)

    0.to_money # TODO
  end

  # The total income to be divided between the organization and payees
  def net_income
    (bandcamp_revenue + distrokid_revenue + merchandise_revenue) - upfront_costs
  end

  # The distribution to the organization, before any contributor donations
  def organization_cut
    organization_distribution * net_income
  end

  # Some contributors may opt to donate their cut to the organization instead
  def donated_royalites
    payout_amounts[:out].values.sum
  end

  # How much the organization keeps, including both cut and donated royalties
  def organization_income
    organization_cut + donated_royalites
  end

  # How much in royalties is owed to each contributor who has not opted out of royalties.
  # Returns Hash[Payee => Money]
  def royalties_owed
    payout_amounts[:in]
  end

  private

  def bandcamp_sales
    @product.bandcamp_sales.where('purchased_at >= ? and purchased_at < ?', @start_at, @end_at)
  end

  def payout_amounts
    @payout_amounts ||= begin
      opted_out, opted_in = @product.payout_amounts(net_income - organization_cut).partition do |payee, _amount|
        payee.opted_out_of_royalties?
      end
      { out: opted_out.to_h, in: opted_in.to_h }
    end
  end

  def organization_distribution
    Rails.application.config.app_config[:organization_cut]
  end
end
