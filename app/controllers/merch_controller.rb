# frozen_string_literal: true

class MerchController < ApplicationController
  before_action :raise_unless_admin!

  def index
    @merch = Merch.order(id: :desc)
    @merch = @merch.where(sku: params[:sku]) if params[:sku]
    @merch = @merch.where('lower(artist_name) like ?', params[:artist].downcase) if params[:artist]
    @merch = @merch.paginate(page: params[:page] || 1, per_page: 200)
  end

  def show
    @merch = Merch.find(params[:id])
    @sales = @merch.bandcamp_sales.includes(:merch_fulfillment)
                   .order(purchased_at: :desc)
                   .paginate(page: params[:page] || 1, per_page: 200)
  end
end
