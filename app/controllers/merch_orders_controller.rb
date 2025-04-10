# frozen_string_literal: true

class MerchOrdersController < ApplicationController
  before_action :raise_unless_admin!

  def index
    @sales = BandcampSale.where(product_type: 'Merch')
    @sales = @sales.order(purchased_at: :desc, bandcamp_transaction_id: :asc, created_at: :desc)
    @sales = @sales.unfulfilled_merch if params[:unfulfilled].to_b
    @sales = @sales.where(bandcamp_transaction_id: params[:bandcamp_transaction_id]) if params[:bandcamp_transaction_id]
    @sales = @sales.where(product_id: params[:merch_id]) if params[:merch_id]
    @sales = @sales.paginate(page: params[:page] || 1, per_page: 200)
  end

  def refund
    @sales = BandcampSale.merch.where(bandcamp_transaction_id: params[:id])
    ActiveRecord::Base.transaction do
      @sales.each { |sale| sale.update!(refunded: true) }
    end
    flash[:success] = 'Order marked as refunded'
    redirect_to merch_orders_path
  rescue StandardError => e
    log_error!(e)
    flash[:danger] = e.message
    redirect_to merch_orders_path
  end
end
