# frozen_string_literal: true

# Clear and re-calculate all cached computations
class RecomputeCacheJob < ApplicationJob
  queue_as :default

  def perform
    CalculatorCache::Manager.recompute_all!
  end
end
