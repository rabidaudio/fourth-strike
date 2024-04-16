# frozen_string_literal: true

class ArtistsController < ApplicationController
  def show
    @artist = Artist.find(params[:id])
  end

  # Search?
  # def index
  # end

  # def new
  # end

  # def edit
  # end

  # def create
  # end

  # def update
  # end
end
