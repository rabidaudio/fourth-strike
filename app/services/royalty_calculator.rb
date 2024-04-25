# frozen_string_literal: true

# This class computes the amount owed to contributors (optionally over a time period).
# TODO: this does a lot of computing in ruby. Doing in the database would be better for performance,
# but we've got small enough data that I'm banking that the performance shouldn't be too bad
class RoyaltyCalculator
  def initialize(from: Time.zone.at(0), to: Time.zone.now, for_payee: nil)
    @start_at = from
    @end_at = to
    @for_payee = for_payee
  end

  def total_payouts
    limit_to_payee(sum_payouts(bandcamp_sale_payouts)) # , distrokid_streams, merch_sales, services_rendered
  end

  def bandcamp_sale_payouts
    sales = BandcampSale
            .includes(:splits, :payees)
            .where('purchased_at >= ? and purchased_at < ?', @start_at, @end_at)
    sales = sales.joins(:payees).merge(Payee.where(id: @for_payee)) if @for_payee.present?
    limit_to_payee(sum_payouts(*sales.map(&:payout_amounts)))
  end

  private

  def limit_to_payee(payouts)
    return payouts if @for_payee.nil?

    { @for_payee => payouts[@for_payee] }
  end

  def sum_payouts(*payouts)
    payouts.each_with_object({}) do |payout, hash|
      payout.each do |payee, amount|
        hash[payee] ||= 0.to_money
        hash[payee] += amount
      end
    end
  end
end
