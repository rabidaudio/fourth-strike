# frozen_string_literal: true

# Download all historical currency conversion data from EU Central Bank
class CurrencyUpdateJob < ApplicationJob
  queue_as :default

  def perform
    CurrencyConversions.load_rates!
  end
end
