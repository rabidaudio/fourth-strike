# frozen_string_literal: true

class RemoveDiscordRequirementFromArtist < ActiveRecord::Migration[8.0]
  def change
    change_column_null(:artists, :discord_handle, true)
  end
end
