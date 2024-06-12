# frozen_string_literal: true

# Re-initialize cache on boot
Rails.application.config.after_initialize do
  Rails.logger.info('Recomputing...')
  CalculatorCache::Manager.recompute_all!
  Rails.logger.info('Compute cache loaded')
end
