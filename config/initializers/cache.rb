# frozen_string_literal: true

# Re-initialize cache on boot
Rails.application.config.after_initialize do
  CalculatorCache::Manager.recompute_all!
end
