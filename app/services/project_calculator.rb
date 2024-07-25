# frozen_string_literal: true

# This class computes the financial situation for an entire project (an album):
# it's digital sales, streaming revenue, merch revenue, and upfront costs.
class ProjectCalculator
  prepend CalculatorCache

  cache_calculations :bandcamp_downloads, :total_streams,
                     :digital_sale_revenue, :streaming_revenue, :merch_revenue,
                     :expenses, :total_royalties, :profit

  def initialize(album)
    @album = album
  end

  def bandcamp_downloads
    bandcamp_album_sales + bandcamp_track_sales + patreon_sales
  end

  def total_streams
    distrokid_album_streams + distrokid_track_streams
  end

  def digital_sale_revenue
    bandcamp_album_sale_revenue + bandcamp_track_sale_revenue + patreon_album_sale_revenue
  end

  def streaming_revenue
    distrokid_album_streaming_revenue + distrokid_track_streaming_revenue
  end

  def merch_revenue
    return 0.to_money if @album.merch_items.empty?

    # Merch revenue is divided evenly amongst all the albums it applies to
    @album.merch_items.map { |m| [RoyaltyCalculator.new(m).gross_revenue, m.albums_count] }
    @album.merch_items.map { |m| RoyaltyCalculator.new(m).gross_revenue / m.albums_count }.sum
  end

  def total_associated_revenue
    digital_sale_revenue + streaming_revenue + merch_revenue
  end

  def expenses
    album_calculator.upfront_costs
  end

  def total_royalties
    all_calculators.map(&:total_royalties_owed).sum
  end

  def profit
    all_calculators.map(&:organization_income).sum - expenses
  end

  def negative?
    expenses > total_associated_revenue
  end

  def totals
    [total_associated_revenue, expenses, total_royalties, profit]
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

  def patreon_sales
    @album.patreon_sales.count
  end

  def distrokid_album_streams
    @album.distrokid_sales.streaming.sum(:quantity)
  end

  def distrokid_track_streams
    DistrokidSale.where(product_type: 'Track', product_id: @album.tracks).streaming.sum(:quantity)
  end

  def bandcamp_album_sale_revenue
    album_calculator.bandcamp_revenue
  end

  def bandcamp_track_sale_revenue
    track_calculators.map(&:bandcamp_revenue).sum
  end

  def patreon_album_sale_revenue
    album_calculator.patreon_digital_revenue
  end

  def distrokid_album_streaming_revenue
    album_calculator.distrokid_revenue
  end

  def distrokid_track_streaming_revenue
    track_calculators.map(&:distrokid_revenue).sum
  end
end
