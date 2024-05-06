# frozen_string_literal: true

class PayeesController < ApplicationController
  def new
    @payee = Payee.new(fsn: Payee.next_fsn)
    @artist = Artist.new(payee: @payee)
  end

  # def edit
  # end

  def create
    ActiveRecord::Base.transaction do
      payee_params = params.require(:payee).permit(:fsn, :name, :paypal_account)

      @payee = Payee.new(payee_params)
      @artist = Artist.new

      if params[:with_artist].to_b
        artist_params = params.require(:payee).require(:artist).permit(:discord_handle, :credit, :contact_info, :bio, :aliases)
        artist_params[:aliases] = artist_params[:aliases].split(',')
        artist_params[:name] = payee_params[:name]
        artist_params[:payee] = @payee
        @artist = Artist.new(artist_params)
        @payee.save!
        @artist.save!
        redirect_to artist_path(@artist)
      else
        @payee.save!
      end
      flash[:success] = "Added #{@payee.name}"
      redirect_to root_path # TODO: admin payees page??
    end
  rescue StandardError => e
    flash[:error] = e.message
    render :new
  end

  # def update
  # end
end
