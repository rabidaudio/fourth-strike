# frozen_string_literal: true

class AmertizeOldMerchCosts < ActiveRecord::Migration[7.2]
  def up
    # There's no gppd shared ID between bandcamp merch orders
    # and either printify (which also hasn't always been used)
    # or the old Home Sheet, so trakcing the actual costs for
    # 2000 historical merch items is incredibly difficult and
    # would need to be done by hand.
    # Instead, we averaged the costs in and out from the home sheet
    # over the given period and it was almost exactly 50%.
    # So we're amertizing the cost for all these old orders
    # and marking them fulfilled at 50% of revenue.
    CalculatorCache::Manager.defer_recompute do
      BandcampSale.unfulfilled_merch.where(purchased_at: ..'2023-07-01').find_each do |sale|
        mf = MerchFulfillment.create!(
          production_cost: (0.5 * sale.net_revenue_amount).round,
          shipped_on: Time.zone.now,
          fulfilled_by_id: nil,
          notes: 'This old merch order was automatically retroactively fulfilled ' \
                 'with an aproximate cost. See 20250414164350_amertize_old_merch_costs.rb'
        )
        sale.update!(merch_fulfillment: mf)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
