# frozen_string_literal: true

# For managing logging in and out of the application
class SessionsController < ApplicationController
  def new; end

  def create
    log_in!
    redirect_to request.env['omniauth.origin'] || root_path
  end

  def destroy
    log_out!
    redirect_to root_path
  end
end
