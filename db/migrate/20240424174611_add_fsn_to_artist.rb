# frozen_string_literal: true

class AddFsnToArtist < ActiveRecord::Migration[7.1]
  def change
    add_column :artists, :fsn, :string, null: false # rubocop:disable Rails/NotNullColumn
    add_index :artists, :fsn, unique: true
  end
end
