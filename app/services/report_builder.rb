# frozen_string_literal: true

# Generates CSV/XLS financial reports.
# `time_range` the (inclusive) start and (exclusive) end of data to include
# `interval` for aggregated reports, the time interval to aggregate on
class ReportBuilder
  attr_reader :time_range, :interval

  ReportData = Struct.new(:row_builder, :items) do
    def initialize(row_builder)
      items = yield
      super(row_builder, items)
    end

    def headers
      row_builder.keys
    end

    def row_data
      iterator = items.respond_to?(:find_each) ? items.find_each : items
      iterator.map do |item|
        row_builder.map do |_key, accessor|
          accessor.is_a?(Symbol) ? item.public_send(accessor) : accessor.call(item)
        end
      end
    end

    def each_row(&block)
      yield headers
      row_data.each(&block)
    end

    def to_csv
      [headers] + row_data
    end
  end

  def initialize(time_range: Time.zone.local(2020, 8, 1)...Time.zone.now, interval: 1.month)
    @time_range = time_range
    @interval = interval
  end

  # How did we do on a per-album basis?
  def project_report # rubocop:disable Metrics/AbcSize
    ReportData.new({
                     'Release Date' => ->(p) { p.album.release_date.to_date.iso8601 },
                     'Album' => ->(p) { p.album.name },
                     'Artist' => ->(p) { p.album.artist_name },
                     'Digital Album Sales' => :bandcamp_downloads,
                     'Streams' => :total_streams,
                     'Digital Sales (Gross)' => ->(p) { p.digital_sale_gross_revenue.round.format },
                     'Digital Sales (Net)' => ->(p) { p.digital_sale_net_revenue.round.format },
                     'Streaming Revenue' => ->(p) { p.streaming_revenue.round.format },
                     'Merch Gross Revenue' => ->(p) { p.merch_gross_revenue.round.format },
                     'Merch Net Revenue' => ->(p) { p.merch_net_revenue.round.format },
                     'Merch Net Revenue (Pending Fulfillment)' => ->(p) { p.merch_net_revenue_payable.round.format },
                     'Merch Cost of Goods' => ->(p) { p.merch_cost_of_goods.round.format },
                     'Merch Payable Income' => ->(p) { p.merch_net_revenue_less_costs.round.format },
                     'Total Gross Revenue' => ->(p) { p.total_gross_revenue.round.format },
                     'Total Net Revenue' => ->(p) { p.total_net_revenue.round.format },
                     'Distributable Income' => ->(p) { p.distributable_income.round.format },
                     'Artist Royalties' => ->(p) { p.artist_royalties.round.format },
                     'Charity Royalites' => ->(p) { p.charity_royalties.round.format },
                     'Organization Income' => ->(p) { p.organization_royalties.round.format },
                     'Project Expenses' => ->(p) { p.production_expenses.round.format },
                     'Organization Profit' => ->(p) { p.organization_profit.round.format }
                   }) do
      Album.order(release_date: :desc).find_each.map do |album|
        ProjectCalculator.new(album, from: time_range.begin, to: time_range.end)
      end
    end
  end

  # TODO: this is wrong because it excludes non-project sales (e.g. some merch)
  # def organization_profit_report
  #   ReportData.new({
  #                    'Time Period Start' => ->(r) { r[:start].to_date.iso8601 },
  #                    'Time Period End' => ->(r) { r[:end].to_date.iso8601 },
  #                    'Organization Profit' => ->(r) { r[:profit].round.format }
  #                  }) do
  #     time_iterator.map do |range|
  #       {
  #         start: range.begin,
  #         end: range.end,
  #         profit: Album.find_each.sum do |album|
  #                   ProjectCalculator.new(album, from: range.begin, to: range.end).organization_profit
  #                 end
  #       }
  #     end
  #   end
  # end

  def payee_report
    ReportData.new({
                     'FSN' => :fsn,
                     'Name' => :name,
                     'Charity?' => ->(p) { p.is_charity? ? 'TRUE' : 'FALSE' },
                     'Donated Royalties?' => ->(p) { p.opted_out_of_royalties? ? 'TRUE' : 'FALSE' },
                     'Royalties Earned' =>
                    ->(p) { p.royalties_owed(from: time_range.begin, to: time_range.end).round.format },
                     'Services Rendered' =>
                    ->(p) { p.services_rendered_owed(from: time_range.begin, to: time_range.end).round.format },
                     'Paid Out' => ->(p) { p.paid_out(from: time_range.begin, to: time_range.end).round.format },
                     'Balance' => ->(p) { p.balance(from: time_range.begin, to: time_range.end).round.format }
                   }) do
      Payee.order(fsn: :asc)
    end
  end

  def bandcamp_digital_sale_report
    ReportData.new({
                     'Purchase Date' => ->(r) { r.purchased_at.to_date.iso8601 },
                     'Bandcamp Transaction ID' => :bandcamp_transaction_id,
                     'Gross Revenue' => ->(r) { r.subtotal_amount.format },
                     'Net Revenue' => ->(r) { r.net_revenue_amount.format },
                     'Product' => ->(r) { "#{r.product_type}/#{r.product_id}" },
                     'Item' => :item_url
                   }) do
      BandcampSale.digital.includes(:product).where(purchased_at: time_range).order(purchased_at: :asc)
    end
  end

  def distrokid_stream_report
    ReportData.new({
                     'Reported Date' => ->(r) { r.reported_at.to_date.iso8601 },
                     'Sale Period' => ->(r) { r.sale_period.to_date.iso8601 },
                     'Title' => :title,
                     'Artist' => :artist_name,
                     'Product' => ->(r) { "#{r.product_type}/#{r.product_id}" },
                     'Quantity' => :quantity,
                     'Store' => :store,
                     'Revenue' => ->(r) { "$#{r.earnings_usd}" }
                   }) do
      DistrokidSale.where(reported_at: time_range).order(reported_at: :asc)
    end
  end

  def bandcamp_merch_sale_report
    ReportData.new({
                     'Purchase Date' => ->(r) { r.purchased_at.to_date.iso8601 },
                     'Bandcamp Transaction ID' => :bandcamp_transaction_id,
                     'Product' => ->(r) { "#{r.product_type}/#{r.product_id}" },
                     'SKU' => :sku,
                     'Option' => :option,
                     'Item' => :item_url,
                     'Gross Revenue' => ->(r) { r.subtotal_amount.format },
                     'Net Revenue' => ->(r) { r.net_revenue_amount.format },
                     'Production Cost' => ->(r) { r.merch_fulfillment&.production_cost&.format },
                     'Shipped Date' => ->(r) { r.merch_fulfillment&.shipped_on&.to_date&.iso8601 }, # rubocop:disable Style/SafeNavigationChainLength
                     'Printify Order' => ->(r) { r.merch_fulfillment&.printify_order_number }
                   }) do
      BandcampSale.merch.includes(:merch_fulfillment).where(purchased_at: time_range).order(purchased_at: :asc)
    end
  end

  def services_rendered_report
    ReportData.new({
                     'Rendered Date' => ->(r) { r.rendered_at.to_date.iso8601 },
                     'Payee' => ->(r) { "#{r.payee.name} / #{r.payee.fsn}" },
                     'Description' => :description,
                     'Project' => ->(r) { r.album&.name },
                     'Type' => :type,
                     'Hours' => ->(r) { r.hours&.to_s },
                     'Compensation' => ->(r) { r.compensation.format }
                   }) do
      RenderedService.includes(:payee, :album).where(rendered_at: time_range).order(rendered_at: :asc)
    end
  end

  def patreon_report
    ReportData.new({
                     'Period' => ->(r) { r.period.to_date.iso8601 },
                     'Customer' => :customer_name_hashed,
                     'Tier' => :tier,
                     'Product' => ->(r) { "#{r.product_type}/#{r.product_id}" },
                     'Proportional Pledge Revenue' => ->(r) { r.proportional_pledge_amount.format },
                     'Net Revenue' => ->(r) { r.net_revenue_amount.format }
                   }) do
      PatreonSale.where(period: time_range).order(period: :asc, customer_name_hashed: :asc)
    end
  end

  def to_combined_xls
    FastExcel.open.tap do |workbook|
      {
        'PROJECTS' => project_report,
        'BANDCAMP DIGITAL SALES' => bandcamp_digital_sale_report,
        'DISTROKID STREAMS' => distrokid_stream_report,
        'BANDCAMP MERCH SALES' => bandcamp_merch_sale_report,
        'SERVICES RENDERED' => services_rendered_report,
        'PATREON' => patreon_report,
        'PAYEES' => payee_report
        # TODO: disabled, too slow (~20min)
        # 'PROFIT' => organization_profit_report
      }.each do |name, report|
        worksheet = workbook.add_worksheet(name)
        report.each_row do |row|
          worksheet.append_row(row)
        end
      end
    end
  end

  def self.time_iterator(time_range, interval)
    Enumerator.new do |y|
      start = time_range.begin
      loop do
        end_ = start + interval
        if end_ > time_range.end
          y << (start...time_range.end)
          break
        end
        y << (start...end_)
        start = end_
      end
    end
  end

  private

  def time_iterator
    self.class.time_iterator(time_range, interval)
  end
end
