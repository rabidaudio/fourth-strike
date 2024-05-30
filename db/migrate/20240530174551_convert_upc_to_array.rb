# frozen_string_literal: true

class ConvertUpcToArray < ActiveRecord::Migration[7.1]
  def change
    remove_index :albums, :upc, unique: true
    rename_column :albums, :upc, :upcs
  end
end
