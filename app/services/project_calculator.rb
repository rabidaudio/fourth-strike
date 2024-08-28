# frozen_string_literal: true

# This class computes the financial situation for an entire project (an album):
# it's digital sales, streaming revenue, merch revenue, and upfront costs.
# It compares album expenses to the organization profit to determine project
# gain/loss.
class ProjectCalculator
  prepend CalculatorCache

  cache_calculations :bandcamp_downloads, :total_streams,
                     :digital_sale_gross_revenue, :digital_sale_net_revenue,
                     :streaming_revenue,
                     :merch_gross_revenue, :merch_cost_of_goods, :merch_net_revenue,
                     :merch_net_revenue_payable, :merch_net_revenue_less_costs,
                     :distributable_income, :artist_royalties, :charity_royalties,
                     :organization_royalties, :production_expenses

  attr_accessor :album

  def initialize(album)
    @album = album
  end

  def bandcamp_downloads
    bandcamp_album_sales + bandcamp_track_sales + patreon_digital_sales
  end

  def total_streams
    distrokid_album_streams + distrokid_track_streams
  end

  def digital_sale_gross_revenue
    bandcamp_album_sale_gross_revenue + bandcamp_track_sale_gross_revenue + patreon_digital_gross_revenue
  end

  def digital_sale_net_revenue
    bandcamp_album_sale_net_revenue + bandcamp_track_sale_net_revenue + patreon_digital_net_revenue
  end

  def streaming_revenue
    distrokid_album_streaming_revenue + distrokid_track_streaming_revenue
  end

  def merch_gross_revenue
    bandcamp_merch_gross_revenue + patreon_merch_gross_revenue + iam8bit_gross_revenue + bandcamp_pledge_gross_revenue
  end

  def merch_cost_of_goods
    merch_calculators.sum(&:cost_of_goods).to_money
  end

  def merch_net_revenue
    bandcamp_merch_net_revenue + patreon_merch_net_revenue +
      iam8bit_net_revenue + bandcamp_pledge_net_revenue
  end

  def merch_net_revenue_payable
    bandcamp_merch_net_revenue_payable + patreon_merch_net_revenue +
      iam8bit_net_revenue + bandcamp_pledge_net_revenue
  end

  def merch_net_revenue_less_costs
    merch_net_revenue_payable - merch_cost_of_goods
  end

  def total_gross_revenue
    digital_sale_gross_revenue + streaming_revenue + merch_gross_revenue
  end

  def total_net_revenue
    digital_sale_net_revenue + streaming_revenue + merch_net_revenue
  end

  def distributable_income
    all_calculators.sum(&:distributable_income).to_money
  end

  def artist_royalties
    all_calculators.map(&:distributable_income).sum(&:total_artist_royalties).to_money
  end

  def charity_royalties
    all_calculators.map(&:distributable_income).sum(&:charity_royalties).to_money
  end

  def payable_royalties
    artist_royalties + charity_royalties
  end

  def organization_royalties
    all_calculators.map(&:distributable_income).sum do |r|
      r.organization_distribution + r.org_royalties + r.donated_royalties
    end
  end

  delegate :production_expenses, to: :album_calculator

  def organization_profit
    organization_royalties - production_expenses
  end

  private

  def album_calculator
    @album_calculator ||= RoyaltyCalculator.new(@album)
  end

  def track_calculators
    @track_calculators ||= @album.tracks.map { |t| RoyaltyCalculator.new(t) }
  end

  def merch_calculators
    @merch_calculators ||= @album.merch_items.map { |m| RoyaltyCalculator.new(m) }
  end

  def all_calculators
    [album_calculator, *track_calculators, *merch_calculators]
  end

  def bandcamp_album_sales
    @album.bandcamp_sales.count
  end

  def bandcamp_track_sales
    BandcampSale.where(product_type: 'Track', product_id: @album.tracks).count
  end

  def patreon_digital_sales
    @album.patreon_sales.count
  end

  def distrokid_album_streams
    @album.distrokid_sales.streaming.sum(:quantity)
  end

  def distrokid_track_streams
    DistrokidSale.where(product_type: 'Track', product_id: @album.tracks).streaming.sum(:quantity)
  end

  def bandcamp_album_sale_gross_revenue
    album_calculator.bandcamp_digital_gross_revenue
  end

  def bandcamp_album_sale_net_revenue
    album_calculator.bandcamp_digital_net_revenue
  end

  def bandcamp_track_sale_gross_revenue
    track_calculators.sum(&:bandcamp_digital_gross_revenue).to_money
  end

  def bandcamp_track_sale_net_revenue
    track_calculators.sum(&:bandcamp_digital_net_revenue).to_money
  end

  def distrokid_album_streaming_revenue
    album_calculator.distrokid_streaming_revenue
  end

  def distrokid_track_streaming_revenue
    track_calculators.sum(&:distrokid_streaming_revenue).to_money
  end

  def bandcamp_merch_gross_revenue
    merch_calculators.sum(&:bandcamp_physical_gross_revenue).to_money
  end

  def bandcamp_merch_net_revenue
    merch_calculators.sum(&:bandcamp_physical_net_revenue).to_money
  end

  def bandcamp_merch_net_revenue_payable
    merch_calculators.sum(&:bandcamp_physical_net_revenue_payable).to_money
  end

  def patreon_digital_gross_revenue
    album_calculator.patreon_gross_revenue
  end

  def patreon_digital_net_revenue
    album_calculator.patreon_net_revenue
  end

  def patreon_merch_gross_revenue
    merch_calculators.sum(&:patreon_gross_revenue).to_money
  end

  def patreon_merch_net_revenue
    merch_calculators.sum(&:patreon_net_revenue).to_money
  end

  def iam8bit_gross_revenue
    merch_calculators.sum(&:iam8bit_gross_revenue).to_money
  end

  def iam8bit_net_revenue
    merch_calculators.sum(&:iam8bit_net_revenue).to_money
  end

  def bandcamp_pledge_gross_revenue
    merch_calculators.sum(&:bandcamp_pledge_gross_revenue).to_money
  end

  def bandcamp_pledge_net_revenue
    merch_calculators.sum(&:bandcamp_pledge_net_revenue).to_money
  end
end
