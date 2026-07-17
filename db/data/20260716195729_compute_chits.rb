# frozen_string_literal: true

class ComputeChits < ActiveRecord::Migration[8.0]
  def up
    Chit.recompute_all!
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
