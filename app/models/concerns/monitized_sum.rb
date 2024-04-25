# frozen_string_literal: true

# Helper for summing Monetized columns across query results.
module MonitizedSum
  extend ActiveSupport::Concern

  class_methods do
    def sum_monetized(field)
      return 0.to_money if current_scope.empty?

      currency_counts = current_scope.regroup("#{field}_currency").count
      raise StandardError, 'Cannot sum payouts in differenct currencies' if currency_counts.size > 1

      currency = currency_counts.to_a.first.first
      cents = current_scope.sum("#{field}_cents")
      # Handle existing groups
      return cents.transform_values { |v| Money.new(v, currency) } if cents.is_a?(Hash)

      Money.new(cents, currency)
    end
  end
end
