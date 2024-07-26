if ENV['CHROME_URL'].present?
  # In production the chrome browser is running in a separate container,
  # so we need to set up the appropriate config settings.
  # Chrome only supports IP or localhost hostnames, so we need to lookup
  # the IP address of the container.
  Rails.application.config.ferrum_browser = {
    url: ENV['CHROME_URL'].sub('chrome', Resolv.getaddress('chrome'))
  }
else
  Rails.application.config.ferrum_browser = {}
end
