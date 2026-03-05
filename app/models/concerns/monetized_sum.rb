# frozen_string_literal: true

# Helper for summing Monetized columns across query results.
module MonetizedSum
  extend ActiveSupport::Concern

  class_methods do
    def sum_monetized(field)
      scope = current_scope || all
      # return 0.to_money if scope.empty?

      currency_counts = scope.regroup("#{field}_currency").count
      return 0.to_money if currency_counts.empty?
      raise StandardError, 'Cannot sum payouts in different currencies' if currency_counts.size > 1

      currency = currency_counts.to_a.first.first
      # currency = Money.default_currency
      cents = scope.sum("#{field}_cents")
      # Handle existing groups
      return cents.transform_values { |v| Money.new(v, currency) } if cents.is_a?(Hash)

      Money.new(cents, currency)
    end
  end
end
