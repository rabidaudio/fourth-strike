# frozen_string_literal: true

# Generates CSV/XLS financial reports.
# `time_range` the (inclusive) start and (exclusive) end of data to include
# `interval` for aggregated reports, the time interval to aggregate on
class ReportBuilder
  attr_reader :time_range, :interval

  Report = Struct.new(:row_builder, :items) do
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
        row_builder.map do |key, accessor|
          accessor.is_a?(Symbol) ? item.public_send(accessor) : accessor.call(item)
        end
      end
    end

    def each_row
      yield headers
      row_data.each do |row|
        yield row
      end
    end

    def to_csv
      [headers] + row_data
    end
  end
  
  def initialize(time_range: Time.zone.local(2020,8,1)...Time.zone.now, interval: 1.month)
    @time_range = time_range
    @interval = interval
  end

  # The total funds incoming to the organization
  # def incoming_report
  #   Report.new({
  #     'Time Period Start' => lambda { |r| r[:start].to_date },
  #     'Time Period End' => lambda { |r| r[:end].to_date },
  #     'Source' => lambda { |r| r[:source] },
  #     'Gross Revenue' => lambda { |r| r[:gross_revenue].format },
  #     'Net Revenue' => lambda { |r| r[:net_revenue].format },
  #     'Org Distribution' => lambda { |r| r[:organization_distribution].format },
  #     'Artist Royalties' => lambda { |r| r[:artist_royalties].format },
  #     'Org Royalties' => lambda { |r| r[:org_royalties].format },
  #     'Donated Royalties' => lambda { |r| r[:donated_royalties].format },
  #     'Total Org Income' => lambda { |r| r[:org_income].format }
  #   }) do
  #     time_iterator.map do |range|
  #       # BANDCAMP DIGITAL SALES
  #       # BANDCAMP MERCH SALES
  #       # iam8bit merch sales
  #       # Distrokid streaming royalties
  #       # Bandcamp campaigns
  #       # Patreon

  #     end.flatten
  #   end
  # end

  # def outgoing_report

  # def project_report

  def bandcamp_digital_sale_report
    Report.new({
      'Purchase Date' => lambda { |r| r.purchased_at.to_date },
      'Bandcamp Transaction ID' => :bandcamp_transaction_id,
      'Gross Revenue' => lambda { |r| r.subtotal_amount.format },
      'Net Revenue' => lambda { |r| r.net_revenue_amount.format },
      'Product' => lambda { |r| "#{r.product_type}/#{r.product_id}" },
      'Item' => :item_url,
    }) do
      BandcampSale.digital.includes(:product).where(purchased_at: time_range).order(purchased_at: :asc)
    end
  end

  def distrokid_stream_report
    Report.new({
      'Reported Date' => lambda { |r| r.reported_at.to_date },
      'Sale Period' => lambda { |r| r.sale_period.to_date },
      'Title' => :title,
      'Artist' => :artist_name,
      'Product' => lambda { |r| "#{r.product_type}/#{r.product_id}" },
      'Quantity' => :quantity,
      'Store' => :store,
      'Revenue' => lambda { |r| "$#{r.earnings_usd.to_s}" },
    }) do
      DistrokidSale.where(reported_at: time_range).order(reported_at: :asc)
    end
  end

  def merch_sale_report
    Report.new({
      'Purchase Date' => lambda { |r| r.purchased_at.to_date },
      'Bandcamp Transaction ID' => :bandcamp_transaction_id,
      'Product' => lambda { |r| "#{r.product_type}/#{r.product_id}" },
      'SKU' => :sku,
      'Option' => :option,
      'Item' => :item_url,
      'Gross Revenue' => lambda { |r| r.subtotal_amount.format },
      'Net Revenue' => lambda { |r| r.net_revenue_amount.format },
      'Production Cost' => lambda { |r| r.merch_fulfillment&.production_cost&.format },
      'Shipped Date' => lambda { |r|  r.merch_fulfillment&.shipped_on&.to_date },
      'Printify Order' => lambda { |r|  r.merch_fulfillment&.printify_order_number }
    }) do
      BandcampSale.merch.includes(:merch_fulfillment).where(purchased_at: time_range).order(purchased_at: :asc)
    end
  end

  def services_rendered_report
    Report.new({
      'Rendered Date' => lambda { |r| r.rendered_at },
      'Payee' => lambda { |r| "#{r.payee.name} / #{r.payee.fsn}" },
      'Description' => :description,
      'Project' => lambda { |r| r.album&.name },
      'Type' => :type,
      'Hours' => lambda { |r| r.hours&.to_s }, 
      'Compensation' => lambda { |r| r.compensation.format }
    }) do
      RenderedService.includes(:payee, :album).where(rendered_at: time_range).order(rendered_at: :asc)
    end
  end

  def patreon_report
    Report.new({
      'Period' => lambda { |r| r.period },
      'Customer' => :customer_name_hashed,
      'Tier' => :tier,
      'Product' => lambda { |r| "#{r.product_type}/#{r.product_id}" },
      'Net Revenue' => lambda { |r| r.net_revenue_amount.format }
    }) do
      PatreonSale.where(period: time_range).order(period: :asc, customer_name_hashed: :asc)
    end
  end

  def to_combined_xls
    FastExcel.open.tap do |workbook|
      {
        # 'FUNDS_IN' => incoming_report,
        # 'FUNDS_OUT' => outgoing_report,
        # 'PROJECTS' => project_report,
        'BANDCAMP DIGITAL SALES' => bandcamp_digital_sale_report,
        'DISTROKID STREAMS' => distrokid_stream_report,
        'MERCH SALES' => merch_sale_report,
        'SERVICES RENDERED' => services_rendered_report,
        'PATREON' => patreon_report
      }.each do |name, report|
        worksheet = workbook.add_worksheet(name)
        report.each_row do |row|
          worksheet.append_row(row)
        end
      end
    end
  end

  private

  def time_iterator
    Enumerator.new do |y|
      start = time_range.begin
      loop do
        _end = start + interval
        if _end > time_range.end
          y << (start...time_range.end)
          break
        end
        y << (start..._end)
        start = _end
      end
    end
  end
end
