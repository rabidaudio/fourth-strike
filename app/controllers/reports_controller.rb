# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :raise_unless_admin!

  def index
    @streaming_data = DistrokidSale.streams_per_month
    @sale_data = BandcampSale.sales_by_month.transform_values { |h| h.transform_values(&:amount) }
    @due_for_payout = Payee.due_for_payout
    @missing_payee_info = Payee.missing_payment_info
    @missing_splits = [Album, Track, Merch].map(&:without_splits).map(&:count).sum
  end
end
