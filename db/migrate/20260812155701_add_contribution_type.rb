# frozen_string_literal: true

class AddContributionType < ActiveRecord::Migration[8.0]
  def change
    add_column :contributions, :level, :integer, null: false, default: 0
  end
end
