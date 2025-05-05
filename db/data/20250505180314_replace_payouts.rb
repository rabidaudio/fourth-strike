# frozen_string_literal: true

class ReplacePayouts < ActiveRecord::Migration[7.2]
  def up
    # remove all non-internal-merch-order payouts that came from the Paypal import script
    Payout.where.missing(:internal_merch_order).destroy_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
