# frozen_string_literal: true

class AlbumsController < ApplicationController
  def index
    @albums = Album.order(release_date: :desc)
    @albums = @albums.where('lower(artist_name) like ?', params[:artist].downcase) if params[:artist]
    @albums = @albums.paginate(page: params[:page] || 1, per_page: 200)
  end

  def show
    @album = Album.find(params[:id])
  end
end
