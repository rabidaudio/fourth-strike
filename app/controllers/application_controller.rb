# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Session
  include FormErrors

  layout 'default'

  before_action :set_locale

  helper_method :base_locale, :region

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def base_locale
    locale_parts[0]
  end

  def region
    locale_parts[1]
  end

  def not_found
    flash[:danger] = "Oops! We couldn't find what you're looking for."
    redirect_to root_path
  end

  protected

  def log_error!(error)
    Rails.logger.error("#{error.class.name}: #{error.message}")
    Rails.logger.error(error.backtrace.join("\n"))
  end

  def per_page
    (params[:limit]&.to_i || 200).clamp(1, 200)
  end

  private

  def set_locale
    # Rails I18n only supports language, not region. But region is useful
    # for other localization, such as LocalizedDatetimeHelper
    I18n.locale = base_locale
  end

  def locale_parts
    l = current_user&.locale
    return [nil, nil] unless l

    l.split('-', 2)
  end
end
