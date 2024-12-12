# frozen_string_literal: true

class ImportsController < ApplicationController
  before_action :raise_unless_admin!

  def index; end

  def import_bandcamp_sales
    load_report(LoadBandcampJob)
  end

  def import_distrokid_streams
    load_report(LoadDistrokidJob)
  end

  private

  def load_report(job_class)
    path = Rails.root.join('storage/exports', params[:report].original_filename)
    File.binwrite(path, params[:report].read)
    job_class.perform_later(path.to_s)
    flash[:success] = 'Loading report. The data will update over the next couple of minutes'
    redirect_to imports_path
  end
end
