# frozen_string_literal: true

class SplitsController < ApplicationController
  before_action :raise_unless_admin!

  before_action :find_product

  def edit
    @splits = @product.splits
    if @product.is_a?(Merch) && params[:copy_from_album].to_b
      @splits = @product.albums.map(&:payees).flatten.uniq.map { |p| Split.new(payee: p, product: @product, value: 1) }
    elsif @product.is_a?(Album) && params[:copy_from_tracks].to_b
      @splits = @product.tracks.map(&:payees).flatten.uniq.map { |p| Split.new(payee: p, product: @product, value: 1) }
    end

    @props = {
      splits: @splits.map { |s| { payee: { name: s.payee.name, fsn: s.payee.fsn }, value: s.value } }
    }
  end

  def update
    ActiveRecord::Base.transaction do
      @product.splits.destroy_all

      params.permit(splits: [:fsn, :value])[:splits].each do |split_params|
        next if split_params[:fsn].blank?

        Split.create!(
          payee: Payee.find_by!(fsn: split_params[:fsn]),
          product: @product,
          value: split_params[:value].to_i
        )
      end
    end
    flash[:success] = 'Splits updated'
    case @product
    when Album then redirect_to album_path(@product)
    when Track then redirect_to album_path(@product.album)
    when Merch then redirect_to merch_path(@product)
    end
  rescue StandardError => e
    flash[:danger] = e.message
    redirect_to edit_splits_path(product_type: @product.class.name.downcase, product_id: @product.id)
  end

  private

  def find_product
    @product = product_type.find(params[:product_id])
  end

  def product_type
    {
      'album' => Album,
      'track' => Track,
      'merch' => Merch
    }[params[:product_type]]
  end
end
