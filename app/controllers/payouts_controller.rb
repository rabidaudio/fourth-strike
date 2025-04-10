# frozen_string_literal: true

class PayoutsController < ApplicationController
  before_action :raise_unless_admin!

  def index
    @payouts = Payout.includes(:payee).order(paid_at: :desc)
    @payouts = @payouts.where(payee_id: params[:payee_id]) if params[:payee_id]
    @payouts = @payouts.paginate(page: params[:page] || 1, per_page: per_page)
  end

  def new
    @payout = Payout.new(payee_id: params[:payee_id], paid_at: Time.zone.today)
    restore_changes!(@payout)
  end

  def create
    ActiveRecord::Base.transaction do
      @payout = Payout.new(new_payout_params)
      @payout.save!
      flash[:success] = "Paid #{@payout.payee.name} #{@payout.amount.format}."
      redirect_to payouts_path
    end
  rescue StandardError => e
    flash[:danger] = e.message
    record_changes!(@payout)
    redirect_to new_payout_path(error: true)
  end

  private

  def new_payout_params
    params.require(:payout).permit(:payee_fsn, :amount_cents, :amount_currency, :paid_at,
                                   :paypal_transaction_id).tap do |payout_params|
      payout_params[:payee_id] = Payee.find_by!(fsn: payout_params.delete(:payee_fsn)).id if payout_params[:payee_fsn]
    end
  end
end
