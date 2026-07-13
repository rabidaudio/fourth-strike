# frozen_string_literal: true

class CreateContributions < ActiveRecord::Migration[8.0]
  def change
    create_table :contributions do |t|
      t.references :track, null: false, foreign_key: true
      t.references :artist, null: false, foreign_key: true
      t.boolean :is_songwriter, null: false, default: false
      t.text :details

      t.timestamps
    end
  end
end
