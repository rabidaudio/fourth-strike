# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_04_16_141435) do
  create_table "artists", force: :cascade do |t|
    t.string "name", null: false
    t.string "credit"
    t.text "aliases", null: false
    t.string "paypal_account"
    t.text "bio"
    t.string "contact_info"
    t.string "discord_handle", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discord_handle"], name: "index_artists_on_discord_handle", unique: true
  end

end
