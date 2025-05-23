# frozen_string_literal: true

# This class computes the amount owed to contributors for a single product (optionally over a time period).
# All methods return Money inless otherwise indicated.
class RoyaltyCalculator
  prepend CalculatorCache

  # An extension of a money class that has splits associated
  # with it. Able to calculate royalty disribution of an
  # arbitrary amount
  class RoyaltyMoney < Money
    attr_accessor :product

    def initialize(money, product)
      super(money.cents, money.currency)
      @product = product
    end

    # The amount of the money that the org receives before calculating splits
    def organization_distribution
      organization_distribution_percentage * to_money
    end

    # How much in royalties is owed to each split payee
    # Returns Hash[Payee => Money]
    def royalties
      @royalties ||= @product.payout_amounts(to_money - organization_distribution)
    end

    # How much in royalties the payee generated in splits. Includes royalties from
    # payees who have donated theirs to the org
    def royalties_earned_by(payee)
      royalties[payee] || 0.to_money(currency)
    end

    # Actual royalties owed
    def royalties_owed_to(payee)
      return 0.to_money if payee.opted_out_of_royalties? || payee.org?

      royalties_earned_by(payee)
    end

    # Total amount of royalties to artists who have chosen to donate
    # their royalties to the org
    def donated_royalties
      royalties.sum do |payee, value|
        payee.opted_out_of_royalties? && !payee.org? ? value : 0.to_money(currency)
      end || 0.to_money(currency)
    end

    # Total value of royalties to charities
    def charity_royalties
      royalties.sum do |payee, value|
        payee.charity? && !payee.org? ? value : 0.to_money(currency)
      end || 0.to_money(currency)
    end

    # Royalties owed to artists expecting payouts
    # Returns Hash[Payee => Money]
    def artist_royalties
      royalties.reject do |payee, _value|
        payee.charity? || payee.opted_out_of_royalties? || payee.org?
      end.to_h
    end

    # Total value of royalties to be paid to artists
    def total_artist_royalties
      # if no splits, just assume proper distribution
      if @product.splits.empty?
        to_money - organization_distribution
      else
        artist_royalties.values.sum || 0.to_money(currency)
      end
    end

    # Value of royalties where the org receives a split
    def org_royalties
      royalties_earned_by(Payee.org)
    end

    def total_org_income
      organization_distribution + org_royalties + donated_royalties
    end

    def to_money
      Money.new(cents, currency)
    end

    def dup_with(options = {})
      RoyaltyMoney.new(Money.new(cents, currency, options), product)
    end

    def +(other)
      other_value = other
      other_value = other.to_money if other.is_a?(RoyaltyMoney)
      value = to_money + other_value

      if other.is_a?(RoyaltyMoney)
        if other.product == product
          RoyaltyMoney.new(value, product)
        else
          value
        end
      else
        RoyaltyMoney.new(value, product)
      end
    end

    private

    def organization_distribution_percentage
      return organization_distribution_merch if product.is_a?(Merch)

      organization_distribution_digital
    end

    def organization_distribution_digital
      Rails.application.config.app_config[:organization_cut][:digital]
    end

    def organization_distribution_merch
      Rails.application.config.app_config[:organization_cut][:merch]
    end
  end

  cache_calculations :production_expenses, :cost_of_goods, :physical_products_sold,
                     :bandcamp_digital_gross_revenue, :bandcamp_digital_net_revenue,
                     :bandcamp_physical_gross_revenue, :bandcamp_physical_net_revenue,
                     :bandcamp_physical_net_revenue_payable,
                     :distrokid_streaming_revenue,
                     :patreon_gross_revenue, :patreon_net_revenue,
                     :iam8bit_gross_revenue, :iam8bit_net_revenue,
                     :bandcamp_pledge_gross_revenue, :bandcamp_pledge_net_revenue

  def initialize(product, from: Time.zone.at(0), to: Time.zone.now)
    @product = product
    @start_at = from
    @end_at = to
  end

  def album?
    @product.is_a?(Album)
  end

  def track?
    @product.is_a?(Track)
  end

  def merch?
    @product.is_a?(Merch)
  end

  # One time expenses for a project. For example: album art, mastering, etc.
  def production_expenses
    return 0.to_money unless @product.is_a?(Album)

    @product.rendered_services.where(rendered_at: @start_at...@end_at).sum_monetized(:compensation)
  end

  # How much did it cost to produce the physical item in question
  def cost_of_goods
    return 0.to_money unless @product.is_a?(Merch)

    MerchFulfillment.joins(:bandcamp_sales).merge(
      BandcampSale.where(id: bandcamp_physical_sales_payable)
    ).sum_monetized(:production_cost)
  end

  def physical_products_sold
    bandcamp_physical_sales_all.sum(&:quantity) + iam8bit_sales.sum(&:quantity) +
      patreon_sales.where(product_type: 'Merch').count
  end

  def bandcamp_digital_gross_revenue
    bandcamp_digital_sales.sum_monetized(:subtotal_amount)
  end

  def bandcamp_digital_net_revenue
    royalty_money(bandcamp_digital_sales.sum_monetized(:net_revenue_amount))
  end

  def bandcamp_physical_gross_revenue
    bandcamp_physical_sales_all.sum_monetized(:subtotal_amount)
  end

  def bandcamp_physical_net_revenue
    bandcamp_physical_sales_all.sum_monetized(:net_revenue_amount)
  end

  # We don't know how much to pay out in royalties for Bandcamp merch until
  # after the merch has been fulfilled, since we don't know the cost of production and shipping.
  # This includes only revenue from fulfilled orders
  def bandcamp_physical_net_revenue_payable
    royalty_money(bandcamp_physical_sales_payable.sum_monetized(:net_revenue_amount))
  end

  def distrokid_streaming_revenue
    royalty_money(distrokid_sales.sum(:earnings_usd).to_money('USD'))
  end

  def patreon_gross_revenue
    patreon_sales.sum_monetized(:proportional_pledge_amount)
  end

  def patreon_net_revenue
    royalty_money(patreon_sales.sum_monetized(:net_revenue_amount))
  end

  def iam8bit_gross_revenue
    return royalty_money(0.to_money) unless @product.is_a?(Merch) && @product.iam8bit?

    iam8bit_sales.sum_monetized(:gross_revenue_amount)
  end

  def iam8bit_net_revenue
    return royalty_money(0.to_money) unless @product.is_a?(Merch) && @product.iam8bit?

    royalty_money(iam8bit_sales.sum_monetized(:net_revenue_amount))
  end

  def bandcamp_pledge_gross_revenue
    return royalty_money(0.to_money) unless @product.is_a?(Merch) && @product.bandcamp_campaign?

    bandcamp_pledges.sum_monetized(:pledge_amount)
  end

  def bandcamp_pledge_net_revenue
    return royalty_money(0.to_money) unless @product.is_a?(Merch) && @product.bandcamp_campaign?

    royalty_money(bandcamp_pledges.sum_monetized(:net_revenue_amount))
  end

  def gross_revenue
    bandcamp_digital_gross_revenue + distrokid_streaming_revenue +
      bandcamp_physical_gross_revenue + patreon_gross_revenue +
      iam8bit_gross_revenue + bandcamp_pledge_gross_revenue
  end

  def net_revenue
    bandcamp_digital_net_revenue + distrokid_streaming_revenue +
      bandcamp_physical_net_revenue + patreon_net_revenue +
      iam8bit_net_revenue + bandcamp_pledge_net_revenue
  end

  def distributable_income
    royalty_money(
      bandcamp_digital_net_revenue + distrokid_streaming_revenue +
      (bandcamp_physical_net_revenue_payable - cost_of_goods) +
      patreon_net_revenue + iam8bit_net_revenue + bandcamp_pledge_net_revenue
    )
  end

  private

  def royalty_money(money)
    RoyaltyMoney.new(money, @product)
  end

  def bandcamp_digital_sales
    @product.bandcamp_sales.digital.where(purchased_at: @start_at...@end_at)
  end

  def bandcamp_physical_sales_all
    @product.bandcamp_sales.merch.where(refunded: false).where(purchased_at: @start_at...@end_at)
  end

  def bandcamp_physical_sales_payable
    @product.bandcamp_sales.merch.where(refunded: false).payable.where(purchased_at: @start_at...@end_at)
  end

  def bandcamp_pledges
    @product.bandcamp_pledges.where(funded_at: @start_at...@end_at)
  end

  def distrokid_sales
    @product.distrokid_sales.where(reported_at: @start_at...@end_at)
  end

  def iam8bit_sales
    @product.iam8bit_sales.where(period: @start_at...@end_at)
  end

  def patreon_sales
    @product.patreon_sales.where(period: @start_at...@end_at)
  end
end
