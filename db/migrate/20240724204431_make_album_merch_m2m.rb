# frozen_string_literal: true

class MakeAlbumMerchM2m < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :merch_items, :albums
    remove_index :merch_items, [:album_id]
    remove_column :merch_items, :album_id, :integer

    create_table :albums_merch_items do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.references :album, null: false, foreign_key: true
      t.references :merch_item, null: false, foreign_key: true
      t.index [:album_id, :merch_item_id], unique: true
    end
  end
end
