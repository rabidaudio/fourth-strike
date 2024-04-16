# frozen_string_literal: true

class CreateArtists < ActiveRecord::Migration[7.1]
  def change
    create_table :artists do |t|
      t.string :name, null: false
      t.string :credit
      t.text :aliases, null: false
      t.string :paypal_account
      t.text :bio
      t.string :contact_info
      t.string :discord_handle, null: false

      t.timestamps
    end
    add_index :artists, :discord_handle, unique: true
  end
end
