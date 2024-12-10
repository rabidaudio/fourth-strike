# frozen_string_literal: true

class CreateReports < ActiveRecord::Migration[7.1]
  def change
    create_table :reports do |t|
      t.timestamp :generated_at, null: false
      t.references :generated_by, null: false, foreign_key: { to_table: :admins }
      t.integer :state, null: false, default: 0
      t.string :filename, null: false
      t.json :args, null: false, default: '{}'

      t.timestamps
    end
  end
end
