# frozen_string_literal: true

namespace :distrokid do
  desc 'Loads Distrokid sale data from their raw data report'
  task :load_report => :environment do
    require 'csv'

    path = Rails.root.glob('exports/DistroKid_*.tsv').first
    raise StandardError, 'Report not found' if path.nil?

    DistrokidReport.upsert_all!(path)
  end
end
