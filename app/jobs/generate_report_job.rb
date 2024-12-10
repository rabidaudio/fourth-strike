# frozen_string_literal: true

# Given a pending Report, generates it, saves it to the filesystem, and updates the status.
class GenerateReportJob < ApplicationJob
  queue_as :default

  def perform(report_id)
    report = Report.find(report_id)

    return unless report.pending?

    report.update!(state: :running)
    FileUtils.mkdir_p(report.path.dirname)
    File.binwrite(report.path, report.builder.to_combined_xls.read_string)
    report.update!(state: :completed)
  rescue StandardError => e
    error_message = (["#{e.class.name}: #{e.message}"] + e.backtrace).join("\n")
    report.update!(state: :failed, error_message: error_message)
    raise e
  end
end
