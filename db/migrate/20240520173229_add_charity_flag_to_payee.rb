# frozen_string_literal: true

class AddCharityFlagToPayee < ActiveRecord::Migration[7.1]
  def change
    add_column :payees, :is_charity, :boolean, null: false, default: false
  end
end
