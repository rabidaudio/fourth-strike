# frozen_string_literal: true

class ImportsController < ApplicationController
  before_action :raise_unless_admin!

  def index; end

  def import_bandcamp_sales
    path = Rails.root.join('storage/exports', params[:report].original_filename)
    File.binwrite(path, params[:report].read)
    LoadBandcampJob.perform_later(path.to_s)
    flash[:success] = 'Loading report. The data will update over the next couple of minutes'
    redirect_to imports_path
  end

  def import_distrokid_streams
    path = Rails.root.join('storage/exports', params[:report].original_filename)
    File.binwrite(path, params[:report].read)
    LoadDistrokidJob.perform_later(path.to_s)
    flash[:success] = 'Loading report. The data will update over the next couple of minutes'
    redirect_to imports_path
  end
end
