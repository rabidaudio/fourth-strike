# frozen_string_literal: true

# Wrapper class for the data returned from Discord OAuth.
#
# Struct example:
# {"provider"=>"discord",
#  "uid"=>"727726489818103859",
#  "info"=>{"name"=>"______", "email"=>nil, "image"=>"https://cdn.discordapp.com/avatars/727726489818103859/5ba1aec93ca5caa13193908a7ac02718"},
#  "credentials"=>{"token"=>"...", "refresh_token"=>"...", "expires_at"=>1713912199, "expires"=>true},
#  "extra"=>
#   {"raw_info"=>
#     {"id"=>"727726489818103859",
#      "username"=>"______",
#      "avatar"=>"5ba1aec93ca5caa13193908a7ac02718",
#      "discriminator"=>"0",
#      "public_flags"=>0,
#      "flags"=>0,
#      "banner"=>nil,
#      "accent_color"=>1096261,
#      "global_name"=>"Julien",
#      "avatar_decoration_data"=>nil,
#      "banner_color"=>"#10BA45",
#      "clan"=>nil,
#      "mfa_enabled"=>false,
#      "locale"=>"en-US",
#      "premium_type"=>0}}}
class User
  include ActiveModel::Model

  attr_accessor :provider, :uid, :info, :credentials, :extra

  def username
    info['name']
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

  def artist
    Artist.find_by(discord_handle: username)
  end

  # admin?
end
