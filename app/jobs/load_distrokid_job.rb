# frozen_string_literal: true

# Import the distrokid stream report at the given path
class LoadDistrokidJob < ApplicationJob
  queue_as :default

  def perform(report_path)
    DistrokidReport.upsert_all!(report_path)
  end
end
