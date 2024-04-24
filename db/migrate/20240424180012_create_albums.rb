# frozen_string_literal: true

class CreateAlbums < ActiveRecord::Migration[7.1]
  def change
    create_table :albums do |t|
      t.string :name, null: false
      t.string :catalog_number, null: false
      t.string :artist_name, null: false
      t.string :bandcamp_url, null: false
      t.timestamp :released_at
      t.string :upc, null: false

      t.timestamps
    end
    add_index :albums, :catalog_number, unique: true
    add_index :albums, :bandcamp_url, unique: true
    add_index :albums, :upc, unique: true
  end
end
