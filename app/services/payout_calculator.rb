# frozen_string_literal: true

# Calculates what a Payee is owed (optionally over a time period). Includes all products and services
# rendered.
class PayoutCalculator
  prepend CalculatorCache

  cache_calculations :for_album_sales, :for_track_sales, :for_merch_sales, :for_services_rendered, :total_owed,
                     :for_royalties

  def initialize(payee, from: Time.zone.at(0), to: Time.zone.now)
    @payee = payee
    @start_at = from
    @end_at = to
  end

  def self.total_owed_for_everyone
    Payee.find_each.map { |payee| PayoutCalculator.new(payee).total_owed }.sum
  end

  def for_album_sales
    @for_album_sales ||= albums.map { |album| royalties_for(album) }.sum
  end

  def for_track_sales
    @for_track_sales ||= tracks.map { |track| royalties_for(track) }.sum
  end

  def for_merch_sales
    # merch.map { |item| royalties_for(item) }.sum
    0.to_money # TODO
  end

  def for_royalties
    [
      for_album_sales,
      for_track_sales,
      for_merch_sales
    ].sum
  end

  def for_services_rendered
    @for_services_rendered ||= services_rendered.sum_monetized(:compensation)
  end

  def total_owed
    [
      for_royalties,
      for_services_rendered
    ].sum
  end

  private

  def royalties_for(product)
    RoyaltyCalculator.new(product, from: @start_at, to: @end_at).royalties_owed_to(@payee)
  end

  def albums
    Album.joins(splits: :payee).where(payees: { id: @payee })
  end

  def tracks
    Track.joins(splits: :payee).where(payees: { id: @payee })
  end

  def merch_items
    # Merch.joins(splits: :payee).where(payees: {id: @payee })
    [] # TODO
  end

  def services_rendered
    @payee.rendered_services.where('rendered_at >= ? and rendered_at < ?', @start_at, @end_at)
  end
end
