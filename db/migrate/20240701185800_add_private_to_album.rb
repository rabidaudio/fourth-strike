# frozen_string_literal: true

class AddPrivateToAlbum < ActiveRecord::Migration[7.1]
  def change
    add_column :albums, :private, :boolean, null: false, default: false
  end
end
