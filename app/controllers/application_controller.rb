# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Session

  layout 'default'

  before_action :set_locale

  private

  def set_locale
    I18n.locale = current_user&.locale
  end
end
