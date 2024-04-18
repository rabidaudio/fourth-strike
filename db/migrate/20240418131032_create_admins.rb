# frozen_string_literal: true

class CreateAdmins < ActiveRecord::Migration[7.1]
  def change
    create_table :admins do |t|
      t.string :discord_handle, null: false
      t.timestamp :granted_at

      t.timestamps
    end
    add_index :admins, :discord_handle, unique: true
  end
end
