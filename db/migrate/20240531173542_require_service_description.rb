# frozen_string_literal: true

class RequireServiceDescription < ActiveRecord::Migration[7.1]
  def change
    change_column_null(:rendered_services, :description, false)
  end
end
