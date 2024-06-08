# frozen_string_literal: true

class RenderedServicesController < ApplicationController
  before_action :raise_unless_admin!

  def index
    @rendered_services = RenderedService.includes(:payee, :album).order(rendered_at: :desc)
    @rendered_services = @rendered_services.where(album_id: params[:album_id]) if params.key?(:album_id)
    @rendered_services = @rendered_services.where(payee_id: params[:payee_id]) if params.key?(:payee_id)
    per_page = (params[:limit]&.to_i || 200).clamp(1, 200)
    @rendered_services = @rendered_services.paginate(page: params[:page] || 1, per_page: per_page)
  end

  def new
    @rendered_service = RenderedService.new(payee: current_user&.artist&.payee, type: :hourly,
                                            rendered_at: Time.zone.today)
    restore_changes!(@rendered_service)
    @props = {
      rendered_service: @rendered_service,
      payee: @rendered_service.payee,
      hourly_rate: RenderedService.hourly_rate.to_f,
      artists: Album.distinct.pluck(:artist_name).sort,
      albums: Album.order(release_date: :desc).pluck(:id, :name).to_h
    }
  end

  def edit
    @rendered_service = RenderedService.find(params[:id])
    restore_changes!(@rendered_service)
    @props = {
      rendered_service: @rendered_service,
      payee: @rendered_service.payee,
      hourly_rate: RenderedService.hourly_rate.to_f,
      artists: Album.distinct.pluck(:artist_name).sort,
      albums: Album.order(release_date: :desc).pluck(:id, :name).to_h
    }
  end

  def create
    @rendered_service = RenderedService.new(service_params)
    @rendered_service.save!
    flash[:success] = 'Added to services rendered'
    redirect_to rendered_services_path
  rescue StandardError => e
    log_error!(e)
    flash[:danger] = e.message
    record_changes!(@rendered_service)
    redirect_to new_rendered_service_path
  end

  def update
    @rendered_service = RenderedService.find(params[:id])
    @rendered_service.assign_attributes(service_params)
    @rendered_service.save!
    flash[:success] = 'Updated services rendered'
    redirect_to rendered_services_path
  rescue StandardError => e
    log_error!(e)
    flash[:danger] = e.message
    record_changes!(@rendered_service)
    redirect_to edit_rendered_service_path(@rendered_service)
  end

  private

  def service_params
    params.require(:rendered_service).permit(
      :rendered_at, :description, :type, :compensation_cents,
      :compensation_currency, :hours, :artist_name, :album_id, payee: :fsn
    ).tap do |service_params|
      service_params[:payee] = if service_params[:payee][:fsn].present?
                                 Payee.find_by!(fsn: service_params[:payee][:fsn])
                               end
    end
  end
end
