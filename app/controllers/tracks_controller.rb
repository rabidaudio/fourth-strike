# frozen_string_literal: true

class TracksController < ApplicationController
  def show
    @track = Track.find(params[:id])
  end
end
