# frozen_string_literal: true

# Calculates what a Payee is owed (optionally over a time period). Includes all products and services
# rendered.
class PayoutCalculator
  def initialize(payee, from: Time.zone.at(0), to: Time.zone.now)
    @payee = payee
    @start_at = from
    @end_at = to
  end

  def self.total_owed_for_everyone(from: Time.zone.at(0), to: Time.zone.now)
    Payee.find_each.index_with { |payee| PayoutCalculator.new(payee, from: from, to: to).total_owed }
  end

  def for_bandcamp_album_sales
    bandcamp_albums.map { |album| royalties_for(album) }.sum
  end

  def for_bandcamp_track_sales
    bandcamp_tracks.map { |track| royalties_for(track) }.sum
  end

  def for_merch_sales
    # bandcamp_tracks.map { |merch| royalties_for(merch) }.sum
    0.to_money # TODO
  end

  def for_distrokid_album_streams
    0.to_money # TODO
  end

  def for_distrokid_track_streams
    0.to_money # TODO
  end

  def for_services_rendered
    # services_rendered.sum_monetized(:amount)
    0.to_money # TODO
  end

  def total_owed
    [
      for_bandcamp_album_sales,
      for_bandcamp_track_sales,
      for_merch_sales,
      for_distrokid_album_streams,
      for_distrokid_track_streams,
      for_services_rendered
    ].sum
  end

  private

  def royalties_for(product)
    RoyaltyCalculator.new(product, from: @start_at, to: @end_at).royalties_owed[@payee] || 0.to_money
  end

  def bandcamp_albums
    Album.joins(splits: :payee).where(payees: { id: @payee })
  end

  def bandcamp_tracks
    Track.joins(splits: :payee).where(payees: { id: @payee })
  end

  def merch_items
    # Merch.joins(splits: :payee).where(payees: {id: @payee })
    # TODO
    []
  end

  def services_rendered
    # @payee.services_rendered.where('rendered_at >= ? and rendered_at < ?', @start_at, @end_at)
    # TODO
    []
  end
end
