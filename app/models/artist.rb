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
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  payee_id       :integer
#
# Indexes
#
#  index_artists_on_discord_handle  (discord_handle) UNIQUE
#  index_artists_on_payee_id        (payee_id)
#
# Foreign Keys
#
#  payee_id  (payee_id => payees.id)
#

# A musician or contributor who worked on a project and who should be paid
# a cut of the proceeds.
#
# Artists must have a name and a discord handle.
# Aliases are a collection of names they might also be known as (nicknames, former/dead names, etc.).
# This information is only visible to admins, and is used for proper attribution. You can choose to
# share this information publicly by putting it in the bio.
# Credit is how they want to be credited on releases.
# Bio is a place to optionally plug themselves on their profile, perhaps link out to other work. It
# supports markdown.
# Contact info is an optional notes field for storing other contact info, it's only visible to
# admins for reaching out in the event that discord isn't an option.
# Payee is a reference to an entity to be paid for this artist's credits. Even if this
# is populated, they may still opt to have their payments go to the organization instead.
#
# Only name, credit, and bio are displayed publicly. The rest of the information is only
# viewable by the artist and admins.
class Artist < ApplicationRecord
  include JsonStringColumn

  belongs_to :payee

  strip_attributes except: [:aliases]
  json_string_attributes :aliases

  delegate :paid_out, to: :payee

  before_save do |artist|
    artist.aliases = artist.aliases.presence || []
  end
end
