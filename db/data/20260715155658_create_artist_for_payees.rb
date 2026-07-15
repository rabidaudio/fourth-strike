# frozen_string_literal: true

class CreateArtistForPayees < ActiveRecord::Migration[8.0]
  def up
    existing = {}
    Artist.find_each do |artist|
      existing[artist.payee.fsn] = artist.slice(:name, :credit, :aliases, :bio, :contact_info, :discord_handle)
    end
    Artist.delete_all

    Payee.artist.find_each do |payee|
      Artist.create!({
        payee: payee,
        name: payee.name
      }.merge(existing[payee.fsn] || {}))
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
