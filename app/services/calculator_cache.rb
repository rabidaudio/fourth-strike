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

    # Should we automatically recompute on write, or simply cache bust and lazy load on the next request
    def eager_recompute?
      return false if Rails.env.test?

      @eager_recompute = true if @eager_recompute.nil?
      @eager_recompute
    end

    def defer_recompute
      @eager_recompute = false
      yield
    ensure
      recompute_all!
      @eager_recompute = true
    end

    def calculator_cache_key(calc_class, *args, **kwargs)
      arg_path = args.map { |a| a.respond_to?(:cache_key) ? a.cache_key : a.to_s }.join('/')
      "calc/#{calc_class.name.underscore}/#{arg_path}?#{kwargs.to_query}"
    end

    def recompute_all!
      # Delete all cached values
      Rails.cache.delete_matched('calc/*')
      # Then trigger a computation of everything
      PayoutCalculator.total_owed_for_everyone
    end

    # This should be called when a sale (BandcampSale or DistrokidSale) is created/updated/destroyed
    def recompute_for_sale!(sale)
      recompute_royalties!(sale.product)
      if sale.product_changed? && sale.changes['product_id'].first.present?
        old_product = sale.changes['product_type'].first.constantize.find_by(id: sale.changes['product_id'])
        recompute_royalties!(old_product) if old_product.present?
      end
    end

    # This should be called when a RenderedService is created/updated/destroyed
    def recompute_for_service_rendered!(service_rendered)
      recompute_royalties!(service_rendered.album) if service_rendered.album

      # if the album was changed and there was an old one, recompute expenses for that too
      if service_rendered.album_changed? && service_rendered.changes['album_id'].first.present?
        old_album = Album.find_by(id: service_rendered.changes['album_id'].first)
        recompute_royalties!(old_album) if old_album.present?
      end

      recompute_payouts!(service_rendered.payee)
      if service_rendered.payee_changed? && service_rendered.changes['payee_id'].first.present?
        old_payee = Payee.find_by(id: service_rendered.changes['payee_id'].first)
        recompute_payouts!(old_payee) if old_payee.present?
      end
    end

    # This should be called when a Split is created/updated/destroyed
    def recompute_for_split!(split)
      recompute_royalties!(split.product)
      recompute_payouts!(split.payee)
    end

    private

    def recompute_royalties!(product)
      now_or_once_per_transaction(RoyaltyCalculator, product) do
        clear_cache(RoyaltyCalculator, product)
        RoyaltyCalculator.new(product).total_royalties_owed if eager_recompute?
        product.payees.find_each do |payee|
          recompute_payouts!(payee)
        end
      end
    end

    def recompute_payouts!(payee)
      now_or_once_per_transaction(PayoutCalculator, payee) do
        clear_cache(PayoutCalculator, payee)
        PayoutCalculator.new(payee).for_services_rendered if eager_recompute?
      end
    end

    def clear_cache(*)
      Rails.cache.delete_matched(/#{Regexp.escape(calculator_cache_key(*))}.*/)
    end

    def now_or_once_per_transaction(calc_class, *, &block)
      return block.call unless AfterCommitEverywhere.in_transaction?

      key = calculator_cache_key(calc_class, *)
      if @pending_transactions.nil?
        @pending_transactions = {}
        AfterCommitEverywhere.after_commit do
          @pending_transactions.each_value do |block|
            block.call
          end
          @pending_transactions = nil
        end
      end
      @pending_transactions[key] ||= block
    end
  end

  def initialize(*, **)
    @key = Manager.calculator_cache_key(self.class, *, **)
    @cache_enabled = true
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
