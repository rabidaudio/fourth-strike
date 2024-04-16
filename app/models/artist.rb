# frozen_string_literal: true

# == Schema Information
#
# Table name: artists
#
#  id             :integer          not null, primary key
#  aliases        :text             not null
#  bio            :text
#  contact_info   :string
#  credit         :string
#  discord_handle :string           not null
#  name           :string           not null
#  paypal_account :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_artists_on_discord_handle  (discord_handle) UNIQUE
#

# A musician or contributor who worked on a project and who should be paid
# a cut of the proceeds.
#
# Artists must have a name and a discord handle.
# Aliases are a collection of names they might also be known as (nicknames, former names, etc.).
# Credit is how they want to be credited on releases.
# Bio is a place to optionally plug themselves on their profile, perhaps link out to other work.
# Contact info is an optional notes field for storing other contact info, it's only visible to
# admins for reaching out in the event that discord isn't an option.
# Paypal account is the email address of the paypal account they wish to be paid. Even if this
# is populated, they may still opt to have their payments go to the organization instead.
#
# Only name, credit, bio, and aliases are displayed publicly. The rest of the information is only
# viewable by the artist and admins.
class Artist < ApplicationRecord
  include JsonStringColumn

  strip_attributes except: [:aliases]
  json_string_attributes :aliases

  before_save do |artist|
    artist.aliases = artist.aliases.presence || []
  end
end
