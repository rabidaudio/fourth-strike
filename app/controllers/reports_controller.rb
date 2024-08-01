# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :raise_unless_admin!

  def index
    @streaming_data = DistrokidSale.streams_per_month
    @sale_data = BandcampSale.sales_by_month.transform_values { |h| h.transform_values(&:amount) }
    @albums = Album.includes(:tracks, :merch_items, :splits).order(release_date: :desc)
  end

  def combined_excel_report
    from = Time.zone.parse(params[:from])
    to = Time.zone.parse(params[:to])
    interval = ActiveSupport::Duration.parse(params[:interval])
    org_name = Rails.application.config.app_config[:organization_name]
    report = ReportBuilder.new(time_range: from...to, interval: interval).to_combined_xls
    send_data report.read_string, filename: "#{org_name.underscore}_reports_#{from.to_date.iso8601}_#{to.to_date.iso8601}.xlsx", disposition: 'attachment'
  end

  def needs_attention
    @due_for_payout = Payee.due_for_payout
    @missing_payee_info = Payee.missing_payment_info
    @missing_splits = [Album, Track, Merch].map(&:without_splits).map(&:count).sum
  end
end
