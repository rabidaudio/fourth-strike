# frozen_string_literal: true

class SplitsController < ApplicationController
  before_action :raise_unless_admin!

  before_action :find_product

  def edit; end

  def append
    render turbo_stream: [
      turbo_stream.append("splits", partial: "splits/split", locals: { split: Split.new })
    ]
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
    redirect_to edit_splits_path(product_type: @product.class.name.downcase, product_id: @product.id)
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
      'track' => Track
      # merch
    }[params[:product_type]]
  end
end
