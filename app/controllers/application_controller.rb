# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Session

  layout 'default'

  before_action :set_locale

  helper_method :base_locale, :region

  def base_locale
    locale_parts[0]
  end

  def region
    locale_parts[1]
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
