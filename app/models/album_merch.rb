# frozen_string_literal: true

# == Schema Information
#
# Table name: albums_merch_items
#
#  id            :integer          not null, primary key
#  album_id      :integer          not null
#  merch_item_id :integer          not null
#
# Indexes
#
#  index_albums_merch_items_on_album_id                    (album_id)
#  index_albums_merch_items_on_album_id_and_merch_item_id  (album_id,merch_item_id) UNIQUE
#  index_albums_merch_items_on_merch_item_id               (merch_item_id)
#
# Foreign Keys
#
#  album_id       (album_id => albums.id)
#  merch_item_id  (merch_item_id => merch_items.id)
#

# A many-to-many join table for albums and merch items. This is necessary because
# some cassettes have multiple albums associated with them.
class AlbumMerch < ApplicationRecord
  self.table_name = 'albums_merch_items'

  belongs_to :album
  belongs_to :merch_item, class_name: 'Merch', counter_cache: 'albums_count'
end
