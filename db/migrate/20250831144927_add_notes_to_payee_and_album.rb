# frozen_string_literal: true

class AddNotesToPayeeAndAlbum < ActiveRecord::Migration[7.2]
  def change
    add_column :payees, :notes, :text
    add_column :albums, :notes, :text
  end
end
