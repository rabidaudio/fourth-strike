# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :raise_unless_admin!

  def index
    @streaming_data = DistrokidSale.streams_per_month
    @sale_data = BandcampSale.sales_by_month.transform_values { |h| h.transform_values(&:amount) }
    @reports = Report.includes(:generated_by).order(generated_at: :desc).paginate(page: params[:page] || 1,
                                                                                  per_page: 50)
  end

  def projects
    @albums = Album.includes(:tracks, :merch_items, :splits).order(release_date: :desc)
    @project_profit_data = @albums.map(&:project).reverse.map do |project|
      {
        name: project.name,
        organization_profit: project.organization_profit.round.to_f,
        # bandcamp_downloads
        streams: project.total_streams
      }
    end
  end

  def combined_excel_report
    from = Time.zone.parse(params[:from])
    to = Time.zone.parse(params[:to])
    report = Report.create!(
      generated_at: Time.zone.now,
      generated_by: current_user.admin,
      args: { begin: from.iso8601, end: to.iso8601, interval: params[:interval] }
    )
    report.generate!
    flash[:success] = 'The report will be ready to download in a few minutes.'
    redirect_to reports_path
  end

  def download
    report = Report.find(params[:id])
    if report.completed?
      send_file(report.path, type: 'application/vnd.ms-excel', disposition: 'attachment')
    else
      flash[:danger] = 'This report is not completed'
      redirect_to reports_path
    end
  end

  def needs_attention
    @due_for_payout = Payee.due_for_payout
    @missing_payee_info = Payee.missing_payment_info
    @missing_splits = [Album, Track, Merch].map(&:without_splits).map(&:count).sum
  end
end
