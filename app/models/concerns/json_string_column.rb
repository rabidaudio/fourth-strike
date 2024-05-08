# frozen_string_literal: true

# A helper which allows setting complex JSON objects, stored as text in the database.
#
# NOTE: unlike using native Postgres JSON columns, these are not easily queryable.
module JsonStringColumn
  extend ActiveSupport::Concern

  class_methods do
    def json_string_attributes(*attributes)
      attributes.map(&:to_s).each do |attribute|
        define_method(attribute) do
          JSON.parse(self[attribute]) if self[attribute].present?
        end

        define_method("#{attribute}=") do |value|
          self[attribute] = if value.is_a?(String)
                              value
                            else
                              value.to_json
                            end
        end
      end
    end
  end
end
