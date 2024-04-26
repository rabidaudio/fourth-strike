# frozen_string_literal: true

class LoosenFieldsForBandcampScript < ActiveRecord::Migration[7.1]
  def change
    change_column_null :albums, :catalog_number, true
    change_column_null :albums, :upc, true

    change_column_null :tracks, :upc, true
    change_column_null :tracks, :isrc, true

    reversible do |dir|
      dir.up do
        change_column :albums, :released_at, :date
        rename_column :albums, :released_at, :release_date
      end
      dir.down do
        rename_column :albums, :release_date, :released_at
        change_column :albums, :released_at, :timestamp
      end
    end
  end
end
