# frozen_string_literal: true

class ContributionsController < ApplicationController
  before_action :raise_unless_admin!

  before_action :find_product

  def edit
    if @product.is_a?(Merch)
      redirect_to(edit_splits_path(product_type: @product.class.name.downcase,
                                   product_id: @product.id))
    end
  end

  def update
    ActiveRecord::Base.transaction do
      create_splits
      create_contributions
    end
    flash[:success] = 'Contributions updated'
    case @product
    when Album then redirect_to album_path(@product)
    when Track then redirect_to track_path(@product)
      # when Merch then redirect_to merch_path(@product)
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
      'track' => Track
      # 'merch' => Merch
    }[params[:product_type]]
  end

  def create_contributions
    if @product.is_a?(Track)
      @product.contributions.destroy_all
    else
      @product.tracks.each { |t| t.contributions.destroy_all }
    end

    return if params[:contributions].nil?

    params.expect(contributions: [[:fsn, :is_songwriter, :details,
                                   :track_id]]).each do |contribution_params|
      next if contribution_params[:fsn].blank?

      artist = Payee.find_by!(fsn: contribution_params[:fsn]).artist
      next unless artist

      Contribution.create!(
        track_id: contribution_params[:track_id],
        artist: artist,
        is_songwriter: contribution_params[:is_songwriter].to_b,
        details: contribution_params[:details]
      )
    end
  end

  def create_splits
    if @product.is_a?(Track)
      @product.splits.destroy_all
    else
      @product.tracks.each { |t| t.splits.destroy_all }
    end

    return if params[:splits].nil?

    params.expect(splits: [[:fsn, :value, :track_id]]).each do |split_params|
      next if split_params[:fsn].blank?

      Split.create!(
        payee: Payee.find_by!(fsn: split_params[:fsn]),
        product: Track.find(split_params[:track_id]),
        value: split_params[:value].to_i
      )
    end
    Chit.recompute_for_product_splits!(@product)
  end
end
