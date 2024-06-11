# frozen_string_literal: true

class AddAlbumToMerch < ActiveRecord::Migration[7.1]
  def change
    add_reference :merch_items, :album, null: true, foreign_key: true
  end
end
