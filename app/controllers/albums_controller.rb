# frozen_string_literal: true

class AlbumsController < ApplicationController
  before_action :raise_unless_logged_in!, except: [:index, :show]

  def index
    @albums = Album.order(release_date: :desc)
    @albums = @albums.where(private: false) unless logged_in? # Hide private albums from public
    @albums = @albums.where('lower(artist_name) like ?', params[:artist].downcase) if params[:artist]
    @albums = @albums.paginate(page: params[:page] || 1, per_page: 200)
  end

  def show
    @album = Album.find(params[:id])
    raise_unless_logged_in! if @album.private?
  end

  def extract_bandcamp_details
    info = BandcampScraper.extract_album_info(params[:url])
    # TODO: serializers?
    render json: {
      album: info.except(:bandcamp_price, :tracks).merge(
        bandcamp_price: { cents: info[:bandcamp_price].cents, currency: info[:bandcamp_price].currency.iso_code }
      ),
      tracks: info[:tracks]
    }
  end

  def new
    @album = Album.new
    restore_changes!(@album)
    @tracks = [Track.new(track_number: 1)]
    @props = {
      album: @album,
      tracks: @tracks
    }
  end

  def edit
    @album = Album.find(params[:id])
    restore_changes!(@album)
    @props = {
      album: @album,
      tracks: @album.tracks
    }
  end

  def create
    @album = Album.new(album_params.except(:tracks))
    @album.tracks = album_params[:tracks].map { |t| Track.new(t) }
    @album.save!
    flash[:success] = 'Album published'
    redirect_to albums_path
  rescue StandardError => e
    log_error!(e)
    flash[:danger] = e.message
    record_changes!(@album)
    redirect_to new_album_path
  end

  def update
    ActiveRecord::Base.transaction do
      @album = Album.find(params[:id])
      @album.assign_attributes(album_params.except(:tracks))
      @album.save!

      album_params[:tracks].each do |track_params|
        track = track_params[:id].present? ? Track.find(track_params[:id]) : Track.new(album: @album)
        track.assign_attributes(track_params.except(:id))
        track.save!
      end
    end
    flash[:success] = 'Updated album'
    redirect_to album_path(@album)
  rescue StandardError => e
    log_error!(e)
    flash[:danger] = e.message
    record_changes!(@album)
    redirect_to edit_album_path(@album)
  end

  private

  def album_params
    params.require(:album).permit(
      :bandcamp_url, :name, :artist_name, :bandcamp_id, :bandcamp_price_cents, :bandcamp_price_currency,
      :album_art_url, :release_date, :catalog_number, :upcs, :private,
      tracks: [:id, :name, :track_number, :bandcamp_url, :isrc, :bandcamp_id, :credits, :lyrics]
    ).tap do |album_params|
      album_params[:private] = album_params[:private].to_b
      album_params[:upcs] = album_params[:upcs].split(',')
      album_params[:bandcamp_price] =
        Money.new(album_params.delete(:bandcamp_price_cents), album_params.delete(:bandcamp_price_currency))
    end
  end
end
