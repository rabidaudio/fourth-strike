# frozen_string_literal: true

class ArtistsController < ApplicationController
  # Search?
  def index; end

  def show
    @artist = Artist.find(params[:id])
  end

  def new
    @payee = Payee.new(fsn: Payee.next_fsn)
    @artist = Artist.new(payee: @payee)
  end

  # def edit
  # end

  def create
    ActiveRecord::Base.transaction do
      payee_params = params.require(:artist).require(:payee).permit(:fsn, :name, :paypal_account)

      @payee = Payee.new(payee_params)
      @artist = Artist.new

      if params[:with_artist].to_b
        artist_params = params.require(:artist).permit(:discord_handle, :credit, :contact_info, :bio)
        artist_params[:aliases] = params.require(:artist)[:aliases].split(',')
        artist_params[:name] = payee_params[:name]
        artist_params[:payee] = @payee
        @artist = Artist.new(artist_params)
      end
      @payee.save!
      @artist.save! if params[:with_artist].to_b

      flash[:success] = "Added #{@payee.name}"
      redirect_to artists_path
    end
  rescue StandardError => e
    flash[:error] = e.message
    render :new
  end

  # def update
  # end
end
