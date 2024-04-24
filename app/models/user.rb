# frozen_string_literal: true

# Wrapper class for the data returned from Discord OAuth.
#
# See sessions_spec for an example of the data structure
class User
  include ActiveModel::Model

  attr_accessor :provider, :uid, :info, :credentials, :extra

  def username
    extra.dig('raw_info', 'username')
  end

  def avatar_url
    info['image']
  end

  def refresh_token
    credentials['refresh_token']
  end

  def expired?
    expires_at <= Time.zone.now
  end

  def expires_soon?
    return false if expired?

    expires_at < 1.day.from_now
  end

  def expires_at
    Time.zone.at(credentials['expires_at'])
  end

  def locale
    extra.dig('raw_info', 'locale')
  end

  def artist
    Artist.find_by(discord_handle: username)
  end

  def artist?
    artist.present?
  end

  def admin
    Admin.find_by(discord_handle: username)
  end

  def admin?
    admin.present?
  end
end
