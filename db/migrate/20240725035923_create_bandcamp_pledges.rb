# frozen_string_literal: true

class CreateBandcampPledges < ActiveRecord::Migration[7.1]
  def change
    create_table :bandcamp_pledges do |t|
      t.string :bandcamp_pledge_id, null: false
      t.string :level
      t.monetize :pledge_amount

      t.timestamps
    end
    add_index :bandcamp_pledges, :bandcamp_pledge_id, unique: true
  end
end
