# frozen_string_literal: true

class CreateSplits < ActiveRecord::Migration[7.1]
  def change
    create_table :splits do |t|
      t.references :payee, null: false, foreign_key: true
      t.references :splittable, null: false, polymorphic: true
      t.integer :value, null: false

      t.timestamps
    end
  end
end
