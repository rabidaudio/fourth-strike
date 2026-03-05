# encoding : utf-8
# frozen_string_literal: true

# Convert Money to different currencies at a specified date of exchange
module CurrencyConversions
  extend self

  # EU Central Bank doesn't publish rates on bank holidays or weekends.
  # This store handles errors when rates can't be found by looking back up
  # to @limit days until rates are available.
  class HistoricalStoreWithDaysOff < Money::RatesStore::StoreWithHistoricalDataSupport
    def initialize(opts = {}, rates = {})
      opts[:limit] ||= 7
      super
    end

    def get_rate(currency_iso_from, currency_iso_to, date = nil)
      return super if date.nil?

      # make sure date is a Date from a time in UTC (i.e. EU time)
      date = date.to_datetime.utc.to_date
      attempts = 0
      loop do
        rate = super

        return rate unless rate.nil?
        return rate if attempts > @options[:limit]

        attempts += 1
        date -= 1.day
      end
    end
  end

  def bank_cache
    Rails.root.join('storage/eu_central_bank_exchange_rates.xml')
  end

  def bank
    @bank ||= EuCentralBank.new(HistoricalStoreWithDaysOff.new).tap do |bank|
      bank.update_historical_rates(bank_cache, true) if File.exist?(bank_cache)
    end
  end

  def load_rates!
    # save all historical rates to storage
    bank.save_rates(bank_cache, EuCentralBank::ECB_ALL_HIST_URL)
    # load them into the money instance
    bank.update_historical_rates(bank_cache, true)
  end

  delegate :exchange_with, to: :bank
end

MoneyRails.configure do |config|
  # To set the default currency
  config.default_currency = Rails.application.config.app_config[:operating_currency]

  # Set default bank object
  config.default_bank = CurrencyConversions.bank
  # NOTE: when using EuCentralBank, make sure explicitly call it using
  # `CurrencyConversions.exchange_with(money, target_currency, date)`
  # so that we account for the historical exchange rate.

  # Add exchange rates to current money bank object.
  # (The conversion rate refers to one direction only)
  #
  # Example:
  # config.add_rate "USD", "CAD", 1.24515
  # config.add_rate "CAD", "USD", 0.803115

  # To handle the inclusion of validations for monetized fields
  # The default value is true
  #
  # config.include_validations = true

  # Default ActiveRecord migration configuration values for columns:
  #
  # config.amount_column = { prefix: '',           # column name prefix
  #                          postfix: '_cents',    # column name  postfix
  #                          column_name: nil,     # full column name (overrides prefix, postfix and accessor name)
  #                          type: :integer,       # column type
  #                          present: true,        # column will be created
  #                          null: false,          # other options will be treated as column options
  #                          default: 0
  #                        }
  #
  # config.currency_column = { prefix: '',
  #                            postfix: '_currency',
  #                            column_name: nil,
  #                            type: :string,
  #                            present: true,
  #                            null: false,
  #                            default: 'USD'
  #                          }

  # Register a custom currency
  #
  # Example:
  # config.register_currency = {
  #   priority:            1,
  #   iso_code:            "EU4",
  #   name:                "Euro with subunit of 4 digits",
  #   symbol:              "€",
  #   symbol_first:        true,
  #   subunit:             "Subcent",
  #   subunit_to_unit:     10000,
  #   thousands_separator: ".",
  #   decimal_mark:        ","
  # }

  # Specify a rounding mode
  # Any one of:
  #
  # BigDecimal::ROUND_UP,
  # BigDecimal::ROUND_DOWN,
  # BigDecimal::ROUND_HALF_UP,
  # BigDecimal::ROUND_HALF_DOWN,
  # BigDecimal::ROUND_HALF_EVEN,
  # BigDecimal::ROUND_CEILING,
  # BigDecimal::ROUND_FLOOR
  #
  # set to BigDecimal::ROUND_HALF_EVEN by default
  #
  config.rounding_mode = BigDecimal::ROUND_HALF_UP

  # Set default money format globally.
  # Default value is nil meaning "ignore this option".
  # Example:
  #
  # config.default_format = {
  #   no_cents_if_whole: nil,
  #   symbol: nil,
  #   sign_before_symbol: nil
  # }

  # If you would like to use I18n localization (formatting depends on the
  # locale):
  config.locale_backend = :i18n
  #
  # Example (using default localization from rails-i18n):
  #
  # I18n.locale = :en
  # Money.new(10_000_00, 'USD').format # => $10,000.00
  # I18n.locale = :es
  # Money.new(10_000_00, 'USD').format # => $10.000,00
  #
  # For the legacy behaviour of "per currency" localization (formatting depends
  # only on currency):
  # config.locale_backend = :currency
  #
  # Example:
  # Money.new(10_000_00, 'USD').format # => $10,000.00
  # Money.new(10_000_00, 'EUR').format # => €10.000,00
  #
  # In case you don't need localization and would like to use default values
  # (can be redefined using config.default_format):
  # config.locale_backend = nil

  # Set default raise_error_on_money_parsing option
  # It will be raise error if assigned different currency
  # The default value is false
  #
  # Example:
  # config.raise_error_on_money_parsing = false
end

Money.default_infinite_precision = true

# This exists to standardize JSON serialization of Money instances
# with SimpleSchemaSerializer's format.
# class Money
#   def to_hash
#     MoneySerializer.serialize(self)
#   end
# end
