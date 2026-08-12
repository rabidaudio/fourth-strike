# frozen_string_literal: true

class MoveSongwriterToLevel < ActiveRecord::Migration[8.0]
  def up
    Contribution.find_each do |c|
      c.update!(level: c.is_songwriter ? :songwriter : :contributor)
    end
  end

  def down
    Contribution.find_each do |c|
      c.update!(is_songwriter: c.songwriter?)
    end
  end
end
