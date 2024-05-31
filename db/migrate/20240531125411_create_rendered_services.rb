# frozen_string_literal: true

class CreateRenderedServices < ActiveRecord::Migration[7.1]
  def change
    create_table :rendered_services do |t|
      t.references :payee, null: false, foreign_key: true
      t.date :rendered_at
      t.integer :type
      t.decimal :hours, precision: 6, scale: 2
      t.text :description
      t.string :artist_name
      t.monetize :compensation
      t.references :album, null: true, foreign_key: true

      t.timestamps
    end
  end
end
