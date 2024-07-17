# frozen_string_literal: true

class Iam8bitSalesController < ApplicationController
  before_action :raise_unless_admin!

  def index
    @iam8bit_sales = Iam8bitSale.order(:period, :name).paginate(page: params[:page] || 1, per_page: 200)
  end

  def new
    @iam8bit_sale = Iam8bitSale.new(period: Time.zone.now.at_beginning_of_quarter.to_date)
  end

  def edit
    @iam8bit_sale = Iam8bitSale.find(params[:id])
  end

  def create
    @iam8bit_sale = Iam8bitSale.new(sale_params)
    @iam8bit_sale.save!
    flash[:success] = 'Sales recorded'
    redirect_to iam8bit_sales_path
  rescue StandardError => e
    log_error!(e)
    flash[:danger] = e.message
    record_changes!(@iam8bit_sale)
    redirect_to new_iam8bit_sale_path
  end

  def update
    @iam8bit_sale = Iam8bitSale.find(params[:id])
    @iam8bit_sale.update!(sale_params)
    flash[:success] = 'Updated sales'
    redirect_to iam8bit_sales_path
  rescue StandardError => e
    flash[:danger] = e.message
    record_changes!(@iam8bit_sale)
    redirect_to edit_iam8bit_sale_path(@iam8bit_sale)
  end

  private

  def sale_params
    params.require(:iam8bit_sale).permit(
      :period, :name, :merch_id, :quantity,
      :gross_revenue_amount_cents, :gross_revenue_amount_currency,
      :net_revenue_amount_cents, :net_revenue_amount_currency
    ).tap do |params|
      params[:product] = Merch.find(params.delete(:merch_id))
    end
  end
end
