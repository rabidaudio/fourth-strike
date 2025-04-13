# frozen_string_literal: true

class MerchFulfillmentsController < ApplicationController
  before_action :raise_unless_admin!

  def new
    @bandcamp_transaction_id = params[:order_id]
    @sales = BandcampSale.unfulfilled_merch.where(bandcamp_transaction_id: params[:order_id])
    @merch_fulfillment = MerchFulfillment.new(shipped_on: Time.zone.today)
    restore_changes!(@merch_fulfillment)
  end

  def edit
    @merch_fulfillment = MerchFulfillment.find(params[:id])
    restore_changes!(@merch_fulfillment)
  end

  def create
    @bandcamp_transaction_id = params[:bandcamp_transaction_id]
    @merch_fulfillment = MerchFulfillment.new(fulfillment_params)
    ActiveRecord::Base.transaction do
      @merch_fulfillment.save!
      @sales = BandcampSale.merch.where(bandcamp_transaction_id: @bandcamp_transaction_id)
      @sales.find_each do |sale|
        sale.update!(merch_fulfillment: @merch_fulfillment)
      end
    end
    flash[:success] = 'Merch order marked shipped'
    redirect_to merch_orders_path
  rescue StandardError => e
    log_error!(e)
    flash[:danger] = e.message
    record_changes!(@merch_fulfillment)
    redirect_to new_merch_fulfillment_path(order_id: @bandcamp_transaction_id)
  end

  def update
    @merch_fulfillment = MerchFulfillment.find(params[:id])
    @merch_fulfillment.assign_attributes(fulfillment_params)
    @merch_fulfillment.save!
    flash[:success] = 'Merch order details updated'
    redirect_to merch_orders_path
  rescue StandardError => e
    log_error!(e)
    flash[:danger] = e.message
    record_changes!(@merch_fulfillment)
    redirect_to edit_merch_fulfillment_path(@merch_fulfillment)
  end

  private

  def fulfillment_params
    params.require(:merch_fulfillment).permit(
      :shipped_on,
      :production_cost_cents, :production_cost_currency,
      :printify_order_number, :notes
    ).tap do |params|
      params[:fulfilled_by_id] = current_user.admin.id
    end
  end
end
