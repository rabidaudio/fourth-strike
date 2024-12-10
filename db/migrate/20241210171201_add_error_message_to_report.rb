# frozen_string_literal: true

class AddErrorMessageToReport < ActiveRecord::Migration[7.1]
  def change
    add_column :reports, :error_message, :text
  end
end
