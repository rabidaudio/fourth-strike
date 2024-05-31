# frozen_string_literal: true

# Calculating accounting and royalties can be pretty slow because the logic is done in Ruby
# instead of in SQL. To work around this, we leverage Rails Cache, re-compute on insert/update,
# and do some trickery to defer recomputation until the end for batch operations.
# For RoyaltyCalculator and PayoutCalculator, it keys by the service arguments, and caches all
# defined methods under them. All they need to do is `prepend CalculatorCache` and indicate which
# methods should be cached.
#
# Use CalculatorCache::Manager to trigger invalidations and re-computations.
module CalculatorCache
  extend ActiveSupport::Concern

  # Used to invalide the cache when data changes
  module Manager
    extend self

    def calculator_cache_key(calc_class, *args, **kwargs)
      "calc/#{calc_class.name.underscore}/#{args.map(&:cache_key).join('/')}?#{kwargs.to_query}"
    end

    def recompute_all!
      # Delete all cached values
      Rails.cache.delete_matched('calc/*')
      # Then trigger a computation of everything
      PayoutCalculator.total_owed_for_everyone
    end

    # This should be called when a sale (BandcampSale or DistrokidSale) is created/updated/destroyed
    def recompute_for_sale!(sale)
      # Rails.cache.delete_matched("calc/royalties_owed")
    end

    # This should be called when a RenderedService is created/updated/destroyed
    def recompute_for_service_rendered!(service_rendered)
      # now_or_at_end_of_transaction do
      #   # Recompute expenses for the album
      #   if service_rendered.album

      #   end

      #   # if the album was changed and there was an old one, recompute expenses for that too
      #   if service_rendered.album_changed? && s.changes['album_id'].first.present?

      #   end

      #   # recompute payee info
      #   PayeeCalculator.new(service_rendered.payee).for_services_rendered
      # end
    end

    # This should be called when a Payout is created/updated/destroyed
    def recompute_for_payout!(payout); end

    # This should be called when a Split is created/updated/destroyed
    def recompute_for_split!(split); end

    private

    def now_or_at_end_of_transaction(&block)
      block.call
      # return block.call unless AfterCommitEverywhere.in_transaction?

      # @pending_
    end
  end

  def initialize(*, **)
    @key = Manager.calculator_cache_key(self.class, *, **)
    super
  end

  class_methods do
    def cache_calculations(*methods)
      @cache_calculation_methods ||= []
      @cache_calculation_methods = @cache_calculation_methods.concat(methods).uniq

      unless methods.empty?
        prepend(Module.new do
          methods.each do |method|
            define_method(method) do |*args|
              if @materializing
                super(*args)
              else
                cached_value[method]
              end
            end
          end
        end)
      end
      @cache_calculation_methods
    end
  end

  private

  def cached_value
    Rails.cache.fetch(@key) do
      materialize do
        self.class.cache_calculations.index_with { |m| send(m) }.to_h
      end
    end
  end

  def materialize
    @materializing = true
    yield
  ensure
    @materializing = false
  end
end
