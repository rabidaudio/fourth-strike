# frozen_string_literal: true

Rails.application.configure do
  config.app_config = YAML.load_file(Rails.root.join('config/app_config.yml')).with_indifferent_access

  config.app_config[:payout_at] =
    Money.new(config.app_config[:payout_at][:cents], config.app_config[:payout_at][:currency])
end
