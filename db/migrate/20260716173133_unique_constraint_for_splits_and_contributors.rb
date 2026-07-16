# frozen_string_literal: true

class UniqueConstraintForSplitsAndContributors < ActiveRecord::Migration[8.0]
  def change
    add_index :splits, [:product_type, :product_id, :payee_id], unique: true
    add_index :contributions, [:track_id, :artist_id], unique: true
  end
end
