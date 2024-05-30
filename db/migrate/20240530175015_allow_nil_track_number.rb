# frozen_string_literal: true

class AllowNilTrackNumber < ActiveRecord::Migration[7.1]
  def change
    change_column_null :tracks, :track_number, true
    remove_index :tracks, :upc, unique: true
    remove_column :tracks, :upc, :string

    change_column_null :tracks, :bandcamp_url, true
  end
end
