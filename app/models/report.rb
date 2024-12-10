# frozen_string_literal: true

# == Schema Information
#
# Table name: reports
#
#  id              :integer          not null, primary key
#  args            :json             not null
#  error_message   :text
#  filename        :string           not null
#  generated_at    :datetime         not null
#  state           :integer          default("pending"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  generated_by_id :integer          not null
#
# Indexes
#
#  index_reports_on_generated_by_id  (generated_by_id)
#
# Foreign Keys
#
#  generated_by_id  (generated_by_id => admins.id)
#

# Reports can take a while to generate, so this table keeps track of progress
# so that the app is still usable while the report is being generated.
class Report < ApplicationRecord
  self.inheritance_column = '_type'

  belongs_to :generated_by, class_name: 'Admin'

  enum :state,
       pending: 0,
       running: 1,
       completed: 2,
       failed: -1

  def generate!
    GenerateReportJob.perform_later(id)
  end

  before_save do |report|
    report.filename ||= default_filename
    report.generated_at ||= Time.zone.now
  end

  after_destroy do |report|
    File.delete(report.path)
  rescue Errno::ENOENT
    # already deleted
  end

  def time_range
    (self.begin...self.end)
  end

  def interval
    ActiveSupport::Duration.parse(args['interval'])
  end

  def path
    Rails.root.join("storage/reports/#{id}/#{filename}")
  end

  def builder
    ReportBuilder.new(time_range: time_range, interval: interval)
  end

  private

  def default_filename
    org_name = Rails.application.config.app_config[:organization_name]
    "#{org_name.underscore}_reports_#{self.begin.to_date.iso8601}_#{self.end.to_date.iso8601}.xlsx"
  end

  def begin
    Time.zone.parse(args['begin'])
  end

  def end
    Time.zone.parse(args['end'])
  end
end
