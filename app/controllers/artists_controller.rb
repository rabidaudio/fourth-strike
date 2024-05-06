# frozen_string_literal: true

class ArtistsController < ApplicationController
  def show
    @artist = Artist.find(params[:id])
  end

  # Search?
  # def index
  # end

  def new
    @payee = Payee.new(fsn: Payee.next_fsn)
    @artist = Artist.new(payee: @payee)
  end

  # def edit
  # end

  # def create
  # end

  # def update
  # end
end
