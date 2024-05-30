# frozen_string_literal: true

# Concern for managing authentication. Looks for Omniauth token data stored in the "user"
# field of session.
module Session
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :logged_in?, :admin?

    rescue_from UnauthenticatedError, with: :render_unauthenticated
  end

  class RefreshTokenError < StandardError; end

  class UnauthenticatedError < StandardError; end

  def current_user
    return @current_user if @current_user.present?
    return nil if session['user'].nil?

    @current_user = User.new(**session['user'])
    return log_out! if @current_user.expired?

    if @current_user.expires_soon?
      begin
        return refresh_token!
      rescue RefreshTokenError => e
        Rails.logger.error(e)
      end
    end
    @current_user
  end

  def logged_in?
    current_user.present?
  end

  def admin?
    current_user&.admin?
  end

  def log_in!
    session['user'] = request.env['omniauth.auth'].to_h
    @current_user = User.new(session['user'])
    unless @current_user.artist? || @current_user.admin?
      flash[:warning] = "No profile exists for discord user #{@current_user.username}. " \
                        "If you need a profile created, contact one of the admins: #{Admin.handles.join(', ')}"
      return log_out!
    end
    @current_user
  end

  def log_out!
    session['user'] = nil
    @current_user = nil
  end

  def raise_unless_logged_in!
    raise UnauthenticatedError, 'Authentication required' unless logged_in?
  end

  def raise_unless_admin!
    raise_unless_logged_in!
    raise UnauthenticatedError, 'Admin access required' unless current_user.admin?
  end

  def render_unauthenticated(error)
    flash[:danger] = error.message
    redirect_to root_path
  end

  private

  # Refresh the access token so they don't have to log in again, and update the stored session
  def refresh_token!
    NetworkError.handle do
      res = HTTP
            .basic_auth(user: ENV.fetch('DISCORD_CLIENT_ID', nil), pass: ENV.fetch('DISCORD_CLIENT_SECRET', nil))
            .post('https://discord.com/api/v10/oauth2/token', form: {
                    grant_type: 'refresh_token',
                    refresh_token: @current_user.refresh_token
                  })

      raise RefreshTokenError, "Token refresh error: [#{res.status}] #{res.body}" if res.status != 200

      token_data = JSON.parse(res.body)
      @current_user.credentials['token'] = token_data['access_token']
      @current_user.credentials['refresh_token'] = token_data['refresh_token']
      @current_user.credentials['expires_at'] = (Time.zone.now + token_data['expires_in'].seconds).to_i
      session['user'] = @current_user.as_json
      @current_user
    end
  rescue NetworkError => e
    raise RefreshTokenError, e
  end
end
