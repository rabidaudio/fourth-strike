# frozen_string_literal: true

class RemoveIsSongwriter < ActiveRecord::Migration[8.0]
  def change
    remove_column :contributions, :is_songwriter, :boolean, null: false, default: false
  end
end
