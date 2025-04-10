# frozen_string_literal: true

class ArtistsController < ApplicationController
  before_action :raise_unless_logged_in!, except: :show

  def show
    @artist = Artist.find(params[:id])
  end

  def new
    @payee = Payee.find(params[:payee_id])
    @artist = Artist.new(payee: @payee, name: @payee.name)
  end

  def edit
    @artist = Artist.find(params[:id])
    restore_changes!(@artist)
  end

  def create
    @artist = Artist.new
    @artist.assign_attributes(artist_params.merge(payee_id: params[:artist][:payee_id]))
    @artist.save!
    flash[:success] = "Created artist profile #{@artist.name} for #{@artist.payee.fsn}"
    redirect_to payees_path
  rescue StandardError => e
    flash[:danger] = e.message
    record_changes!(@artist)
    redirect_to new_artist_path(payee_id: params[:artist][:payee_id])
  end

  def update
    ActiveRecord::Base.transaction do
      @artist = Artist.find(params[:id])

      @artist.update!(artist_params)
      @artist.payee.update!(payee_params) if payee_params.present?
    end
    flash[:success] = 'Updated artist information'
    redirect_to artist_path(@artist)
  rescue StandardError => e
    flash[:danger] = e.message
    record_changes!(@artist)
    redirect_to edit_artist_path(@artist)
  end

  private

  def artist_params
    params.require(:artist).permit(:name, :discord_handle, :credit, :contact_info, :bio,
                                   :aliases).tap do |artist_params|
      artist_params[:aliases] = artist_params[:aliases].split(',')
    end
  end

  def payee_params
    params.require(:artist).require(:payee).permit(:paypal_account, :opted_out_of_royalties)
  end
end
