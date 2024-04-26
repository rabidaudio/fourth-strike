# frozen_string_literal: true

class AddArtToAlbum < ActiveRecord::Migration[7.1]
  def change
    add_column :albums, :album_art_url, :string
  end
end
