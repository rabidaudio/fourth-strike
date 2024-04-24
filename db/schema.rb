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

ActiveRecord::Schema[7.1].define(version: 2024_04_24_174611) do
  create_table "admins", force: :cascade do |t|
    t.string "discord_handle", null: false
    t.datetime "granted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discord_handle"], name: "index_admins_on_discord_handle", unique: true
  end

  create_table "artists", force: :cascade do |t|
    t.string "name", null: false
    t.string "credit"
    t.text "aliases", null: false
    t.text "bio"
    t.string "contact_info"
    t.string "discord_handle", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "payee_id"
    t.string "fsn", null: false
    t.index ["discord_handle"], name: "index_artists_on_discord_handle", unique: true
    t.index ["fsn"], name: "index_artists_on_fsn", unique: true
    t.index ["payee_id"], name: "index_artists_on_payee_id"
  end

  create_table "payees", force: :cascade do |t|
    t.string "paypal_account"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["paypal_account"], name: "index_payees_on_paypal_account", unique: true
  end

  create_table "payouts", force: :cascade do |t|
    t.integer "payee_id", null: false
    t.datetime "paid_at"
    t.string "paypal_transaction_id"
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payee_id"], name: "index_payouts_on_payee_id"
    t.index ["paypal_transaction_id"], name: "index_payouts_on_paypal_transaction_id", unique: true
  end

  add_foreign_key "artists", "payees"
  add_foreign_key "payouts", "payees"
end
