# frozen_string_literal: true

class PayeesController < ApplicationController
  before_action :raise_unless_admin!

  def index
    @payees = Payee.order(fsn: :desc)
    @payees = @payees.search(params[:search]) if params[:search].present?
    per_page = (params[:limit]&.to_i || 200).clamp(1, 200)
    @payees = @payees.paginate(page: params[:page] || 1, per_page: per_page)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update('search_results', partial: 'payees/table', locals: { payees: @payees })
        ]
      end
      format.json do
        render json: @payees.map { |p| p.slice(:name, :fsn) }
      end
      format.html do
        render :index
      end
    end
  end

  def new
    @payee = Payee.new(fsn: Payee.next_fsn)
    @artist = Artist.new(payee: @payee)
    restore_changes!(@payee)
    restore_changes!(@artist)
  end

  def edit
    @payee = Payee.find(params[:id])
    restore_changes!(@payee)
  end

  def create
    ActiveRecord::Base.transaction do
      @payee = Payee.new(new_payee_params)
      @artist = Artist.new
      @artist.assign_attributes(new_artist_params) if params[:with_artist].to_b
      @payee.save!
      @artist.save! if params[:with_artist].to_b
      flash[:success] = "Added #{@payee.name}"
      redirect_to payees_path
    end
  rescue StandardError => e
    flash[:error] = e.message
    record_changes!(@payee)
    record_changes!(@artist)
    redirect_to new_payee_path(with_artist: params[:with_artist])
  end

  def update
    ActiveRecord::Base.transaction do
      @payee = Payee.find(params[:id])
      @payee.update!(params.require(:payee).permit(:name, :paypal_account))
      flash[:success] = 'Updated'
      redirect_to payees_path
    end
  rescue StandardError => e
    flash[:error] = e.message
    record_changes!(@payee)
    redurect_to edit_payee_path(@payee)
  end

  private

  def new_payee_params
    params.require(:payee).permit(:fsn, :name, :paypal_account)
  end

  def new_artist_params
    artist_params = params
                    .require(:payee)
                    .require(:artist)
                    .permit(:discord_handle, :credit, :contact_info, :bio, :aliases)
    artist_params[:aliases] = (artist_params[:aliases] || '').split(',')
    artist_params[:name] = new_payee_params[:name]
    artist_params[:payee] = @payee
    artist_params
  end
end
