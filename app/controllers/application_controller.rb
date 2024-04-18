# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Session

  layout 'default'
end
