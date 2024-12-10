# frozen_string_literal: true

# Require that the user be an admin and logged in before accessing content
class RequireAuthenticatedAdminMiddleware
  def initialize(app, *)
    @app = app
  end

  def call(env)
    if logged_in?(env)
      @app.call(env)
    else
      [401, {}, []]
    end
  end

  private

  def logged_in?(env)
    req = ActionDispatch::Request.new(env)
    return false unless req.session['user'].present?

    current_user = User.new(**req.session['user'])
    return false if current_user.expired?

    current_user.admin?
  end
end

DelayedJobWeb.use(RequireAuthenticatedAdminMiddleware)
