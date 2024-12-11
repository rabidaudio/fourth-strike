# frozen_string_literal: true

# Import the bandcamp raw data report at the given path
class LoadBandcampJob < ApplicationJob
  queue_as :default

  def perform(report_path)
    BandcampReport.load_report!(report_path)
  end
end
