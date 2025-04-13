# frozen_string_literal: true

class MerchFulfillmentsController < ApplicationController
  before_action :raise_unless_admin!

  def new
    @sales = BandcampSale.unfulfilled_merch.where(bandcamp_transaction_id: params[:order_id])
    @merch_fulfillment = MerchFulfillment.new(bandcamp_sale: @sale, shipped_on: Time.zone.today)
    restore_changes!(@merch_fulfillment)
  end

  def edit
    @merch_fulfillment = MerchFulfillment.find(params[:id])
    @sale = @merch_fulfillment.bandcamp_sale
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

  def update
    @merch_fulfillment = MerchFulfillment.find(params[:id])
    @merch_fulfillment.assign_attributes(fulfillment_params)
    @merch_fulfillment.save!
    flash[:success] = 'Merch order details updated'
    redirect_to merch_fulfillments_path
  rescue StandardError => e
    log_error!(e)
    flash[:danger] = e.message
    record_changes!(@merch_fulfillment)
    redirect_to edit_merch_fulfillment_path(@merch_fulfillment)
  end

  private

  def fulfillment_params
    params.require(:merch_fulfillments).permit([:bandcamp_sale_id, :shipped_on,
                                                :production_cost_cents, :production_cost_currency,
                                                :printify_order_number, :notes]).each do |params|
      params[:fulfilled_by_id] = current_user.admin.id
    end
  end
end
