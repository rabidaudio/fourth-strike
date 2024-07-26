if Rails.env.production?
  # In production the chrome browser is running in a separate container,
  # so we need to set up the appropriate config settings.
  Rails.application.config.ferrum_browser = {
    url: ENV['CHROME_URL'].sub('chrome', Resolv.getaddress('chrome'))
  }
else
  Rails.application.config.ferrum_browser = {}
end
