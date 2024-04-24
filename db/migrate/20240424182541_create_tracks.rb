# frozen_string_literal: true

class CreateTracks < ActiveRecord::Migration[7.1]
  def change
    create_table :tracks do |t|
      t.string :name, null: false
      t.references :album, null: false, foreign_key: true
      t.integer :track_number, null: false
      t.string :isrc, null: false
      t.string :upc, null: false
      t.string :bandcamp_url, null: false
      t.text :lyrics
      t.text :credits

      t.timestamps
    end
    add_index :tracks, :isrc, unique: true
    add_index :tracks, :upc, unique: true
    add_index :tracks, [:album_id, :track_number], unique: true
    add_index :tracks, :bandcamp_url, unique: true
  end
end
