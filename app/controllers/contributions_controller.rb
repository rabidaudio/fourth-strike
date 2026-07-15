# frozen_string_literal: true

class ContributionsController < ApplicationController
  before_action :raise_unless_admin!

  before_action :find_product

  def edit
    if @product.is_a?(Merch) && params[:copy_from_album].to_b
      @splits = @product.albums.map(&:payees).flatten.uniq.map { |p| Split.new(payee: p, product: @product, value: 1) }
    elsif @product.is_a?(Album)
      if params[:copy_from_tracks].to_b
        @splits = @product.tracks.map(&:payees).flatten.uniq.map do |p|
          Split.new(payee: p, product: @product, value: 1)
        end
      end
    elsif @product.is_a?(Track)
      @contributions = @product.contributions
      @splits = @product.splits
    end
  end

  def update
    ActiveRecord::Base.transaction do
      @product.splits.destroy_all
      create_splits

      if @product.is_a?(Track)
        @product.contributions.destroy_all
        create_contributions
      end
    end
    flash[:success] = 'Contributions updated'
    case @product
    when Album then redirect_to album_path(@product)
    when Track then redirect_to track_path(@product)
    when Merch then redirect_to merch_path(@product)
    end
  rescue StandardError => e
    flash[:danger] = e.message
    redirect_to edit_contributions_path(product_type: @product.class.name.downcase, product_id: @product.id)
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

  def create_contributions
    params.permit(contributions: [:fsn, :is_songwriter, :details])[:contributions].each do |contribution_params|
      next if contribution_params[:fsn].blank?

      artist = Payee.find_by!(fsn: contribution_params[:fsn]).artist
      next unless artist

      Contribution.create!(
        track: @product,
        artist: artist,
        is_songwriter: params[:is_songwriter].to_b,
        details: params[:details]
      )
    end
  end

  def create_splits
    params.permit(splits: [:fsn, :value])[:splits].each do |split_params|
      next if split_params[:fsn].blank?

      Split.create!(
        payee: Payee.find_by!(fsn: split_params[:fsn]),
        product: @product,
        value: split_params[:value].to_i
      )
    end
  end
end
