# frozen_string_literal: true

# == Schema Information
#
# Table name: admins
#
#  id             :integer          not null, primary key
#  discord_handle :string           not null
#  granted_at     :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_admins_on_discord_handle  (discord_handle) UNIQUE
#

# A discord user who has special permissions to view and edit data.
class Admin < ApplicationRecord
  after_initialize do |admin|
    admin.granted_at ||= Time.zone.now
  end

  def self.handles
    order(granted_at: :asc).pluck(:discord_handle)
  end
end
