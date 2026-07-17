# frozen_string_literal: true

class CreateChits < ActiveRecord::Migration[8.0]
  def change
    create_table :chits do |t|
      t.references :sale, null: true, polymorphic: true
      t.references :product, null: true, polymorphic: true
      t.references :rendered_service, null: true
      t.references :payee, null: false
      t.float :earnings_usd, null: false
      t.timestamp :earned_at, null: false
      t.timestamps
    end

    # ensure one chit per transaction and payee
    add_index :chits, [:sale_type, :sale_id, :rendered_service_id, :payee_id], unique: true
    add_index :chits, :earned_at
  end
end
