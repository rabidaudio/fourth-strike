# frozen_string_literal: true

# Utility methods for generating fake data
module FactoryUtils
  extend self

  def sanitize_for_url(str)
    str.gsub(' ', '_').downcase.dasherize.gsub(/[^a-z\-]/, '')
  end
end
