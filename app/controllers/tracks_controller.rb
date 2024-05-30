# frozen_string_literal: true

class TracksController < ApplicationController
  def show
    @track = Track.find(params[:id])

    raise ActiveRecord::RecordNotFound if @track.hidden? && !admin?
  end
end
