# frozen_string_literal: true

class AddOptOutFlagToPayee < ActiveRecord::Migration[7.1]
  def change
    add_column :payees, :opted_out_of_royalties, :boolean, null: false, default: false
  end
end
