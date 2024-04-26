# frozen_string_literal: true

class AddBandcampIds < ActiveRecord::Migration[7.1]
  def change
    add_column :albums, :bandcamp_id, :string
    add_column :tracks, :bandcamp_id, :string

    add_index :albums, :bandcamp_id, unique: true
    add_index :tracks, :bandcamp_id, unique: true
  end
end
