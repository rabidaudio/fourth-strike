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

ActiveRecord::Schema[7.1].define(version: 2024_04_29_153212) do
  create_table "admins", force: :cascade do |t|
    t.string "discord_handle", null: false
    t.datetime "granted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discord_handle"], name: "index_admins_on_discord_handle", unique: true
  end

  create_table "albums", force: :cascade do |t|
    t.string "name", null: false
    t.string "catalog_number"
    t.string "artist_name", null: false
    t.string "bandcamp_url", null: false
    t.date "release_date"
    t.string "upc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "album_art_url"
    t.string "bandcamp_id"
    t.index ["bandcamp_id"], name: "index_albums_on_bandcamp_id", unique: true
    t.index ["bandcamp_url"], name: "index_albums_on_bandcamp_url", unique: true
    t.index ["catalog_number"], name: "index_albums_on_catalog_number", unique: true
    t.index ["upc"], name: "index_albums_on_upc", unique: true
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
    t.index ["discord_handle"], name: "index_artists_on_discord_handle", unique: true
    t.index ["payee_id"], name: "index_artists_on_payee_id"
  end

  create_table "bandcamp_sales", force: :cascade do |t|
    t.integer "quantity", null: false
    t.text "notes"
    t.string "item_url", null: false
    t.string "sku"
    t.string "upc"
    t.string "bandcamp_transaction_id"
    t.string "paypal_transaction_id"
    t.integer "subtotal_amount_cents", default: 0, null: false
    t.string "subtotal_amount_currency", default: "USD", null: false
    t.integer "net_revenue_amount_cents", default: 0, null: false
    t.string "net_revenue_amount_currency", default: "USD", null: false
    t.datetime "purchased_at", null: false
    t.string "product_type", null: false
    t.integer "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bandcamp_transaction_id"], name: "index_bandcamp_sales_on_bandcamp_transaction_id", unique: true
    t.index ["item_url"], name: "index_bandcamp_sales_on_item_url"
    t.index ["paypal_transaction_id"], name: "index_bandcamp_sales_on_paypal_transaction_id"
    t.index ["product_type", "product_id"], name: "index_bandcamp_sales_on_product"
    t.index ["upc"], name: "index_bandcamp_sales_on_upc"
  end

  create_table "payees", force: :cascade do |t|
    t.string "paypal_account"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.string "fsn", null: false
    t.index ["fsn"], name: "index_payees_on_fsn", unique: true
    t.index ["paypal_account"], name: "index_payees_on_paypal_account"
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

  create_table "splits", force: :cascade do |t|
    t.integer "payee_id", null: false
    t.string "product_type", null: false
    t.integer "product_id", null: false
    t.integer "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payee_id"], name: "index_splits_on_payee_id"
    t.index ["product_type", "product_id"], name: "index_splits_on_product"
  end

  create_table "tracks", force: :cascade do |t|
    t.string "name", null: false
    t.integer "album_id", null: false
    t.integer "track_number", null: false
    t.string "isrc"
    t.string "upc"
    t.string "bandcamp_url", null: false
    t.text "lyrics"
    t.text "credits"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "bandcamp_id"
    t.index ["album_id", "track_number"], name: "index_tracks_on_album_id_and_track_number", unique: true
    t.index ["album_id"], name: "index_tracks_on_album_id"
    t.index ["bandcamp_id"], name: "index_tracks_on_bandcamp_id", unique: true
    t.index ["bandcamp_url"], name: "index_tracks_on_bandcamp_url", unique: true
    t.index ["isrc"], name: "index_tracks_on_isrc", unique: true
    t.index ["upc"], name: "index_tracks_on_upc", unique: true
  end

  add_foreign_key "artists", "payees"
  add_foreign_key "payouts", "payees"
  add_foreign_key "splits", "payees"
  add_foreign_key "tracks", "albums"
end
