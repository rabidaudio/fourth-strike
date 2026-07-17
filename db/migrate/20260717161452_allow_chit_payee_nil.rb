# frozen_string_literal: true

class AllowChitPayeeNil < ActiveRecord::Migration[8.0]
  def change
    change_column_null(:chits, :payee_id, true)
  end
end
