# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FourthStrike
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    Rails.autoloaders.log! if ENV.fetch('DEBUG', 'false') == 'true'

    config.action_mailer.preview_path = config.root.join('spec/mailers/previews')

    # config.redis_config = {
    #   url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1'),
    #   db: ENV.fetch('REDIS_DB', nil),
    # }

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.generators do |g|
      g.orm :active_record, migration: true
      g.template_engine :erb
      g.test_framework  :rspec,
                        fixtures: true,
                        view_specs: false,
                        helper_specs: false,
                        controller_specs: false,
                        request_specs: false
      g.stylesheets false
      g.helper false
    end
  end
end
