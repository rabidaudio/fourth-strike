# frozen_string_literal: true

class MerchFulfillmentsController < ApplicationController
  before_action :raise_unless_admin!

  def index
    @merch = BandcampSale.where(product_type: 'Merch')
    @merch = @merch.unfulfilled_merch if params['unfulfilled'].to_b
    @merch = @merch.order(purchased_at: :desc)
    @merch = @merch.where(product_id: params[:merch_id]) if params[:merch_id]
    @merch = @merch.paginate(page: params[:page] || 1, per_page: 200)
  end

  def new
    @sale = BandcampSale.unfulfilled_merch.find(params[:sale_id])
    @merch_fulfillment = MerchFulfillment.new(bandcamp_sale: @sale, shipped_on: Time.zone.today)
    restore_changes!(@merch_fulfillment)
  end

  def create
    @merch_fulfillment = MerchFulfillment.new(fulfillment_params)
    @merch_fulfillment.save!
    flash[:success] = 'Merch order marked shipped'
    redirect_to merch_fulfillments_path
  rescue StandardError => e
    log_error!(e)
    flash[:danger] = e.message
    record_changes!(@merch_fulfillment)
    redirect_to new_merch_fulfillment_path
  end

  private

  def fulfillment_params
    params.require(:merch_fulfillment).permit(:bandcamp_sale_id, :shipped_on, :production_cost_cents,
                                              :production_cost_currency, :printify_order_number, :notes).tap do |params|
      params[:fulfilled_by_id] = current_user.admin.id
    end
  end
end
