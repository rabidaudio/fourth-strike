# frozen_string_literal: true

class ArtistsController < ApplicationController
  before_action :raise_unless_logged_in!, except: :show

  def show
    @artist = Artist.find(params[:id])
  end

  def edit
    @artist = Artist.find(params[:id])
    restore_changes!(@artist)
  end

  def update
    @artist = Artist.find(params[:id])
    artist_params = params.require(:artist).permit(:name, :discord_handle, :credit, :contact_info, :bio, :aliases)
    artist_params[:aliases] = artist_params[:aliases].split(',')

    @artist.update!(artist_params)
    flash[:success] = 'Updated artist information'
    redirect_to artist_path(@artist)
  rescue StandardError => e
    flash[:danger] = e.message
    record_changes!(@artist)
    redirect_to edit_artist_path(@artist)
  end
end
