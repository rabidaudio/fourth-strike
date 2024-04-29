# frozen_string_literal: true

class AddNameToPayee < ActiveRecord::Migration[7.1]
  def change
    add_column :payees, :name, :string, null: false # rubocop:disable Rails/NotNullColumn
    add_column :payees, :fsn, :string, null: false # rubocop:disable Rails/NotNullColumn

    add_index :payees, :fsn, unique: true

    reversible do |dir|
      dir.up do
        remove_column :artists, :fsn
      end
      dir.down do
        add_column :artists, :fsn, :string, null: false # rubocop:disable Rails/NotNullColumn

        add_index :artists, :fsn, unique: true
      end
    end
  end
end
