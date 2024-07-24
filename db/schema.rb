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

ActiveRecord::Schema[7.1].define(version: 2024_07_24_204431) do
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
    t.string "upcs"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "album_art_url"
    t.string "bandcamp_id"
    t.integer "bandcamp_price_cents", default: 0, null: false
    t.string "bandcamp_price_currency", default: "USD", null: false
    t.boolean "private", default: false, null: false
    t.index ["bandcamp_id"], name: "index_albums_on_bandcamp_id", unique: true
    t.index ["bandcamp_url"], name: "index_albums_on_bandcamp_url", unique: true
    t.index ["catalog_number"], name: "index_albums_on_catalog_number", unique: true
  end

  create_table "albums_merch_items", force: :cascade do |t|
    t.integer "album_id", null: false
    t.integer "merch_item_id", null: false
    t.index ["album_id", "merch_item_id"], name: "index_albums_merch_items_on_album_id_and_merch_item_id", unique: true
    t.index ["album_id"], name: "index_albums_merch_items_on_album_id"
    t.index ["merch_item_id"], name: "index_albums_merch_items_on_merch_item_id"
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
    t.string "option"
    t.index ["bandcamp_transaction_id", "item_url"], name: "index_bandcamp_sales_on_bandcamp_transaction_id_and_item_url", unique: true
    t.index ["item_url"], name: "index_bandcamp_sales_on_item_url"
    t.index ["paypal_transaction_id"], name: "index_bandcamp_sales_on_paypal_transaction_id"
    t.index ["product_type", "product_id"], name: "index_bandcamp_sales_on_product"
    t.index ["upc"], name: "index_bandcamp_sales_on_upc"
  end

  create_table "distrokid_sales", force: :cascade do |t|
    t.date "sale_period"
    t.date "reported_at"
    t.string "store"
    t.string "artist_name"
    t.string "title"
    t.string "isrc"
    t.string "upc"
    t.integer "quantity"
    t.string "product_type", null: false
    t.integer "product_id", null: false
    t.decimal "earnings_usd"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["isrc"], name: "index_distrokid_sales_on_isrc"
    t.index ["product_type", "product_id"], name: "index_distrokid_sales_on_product"
    t.index ["reported_at"], name: "index_distrokid_sales_on_reported_at"
    t.index ["upc"], name: "index_distrokid_sales_on_upc"
  end

  create_table "iam8bit_sales", force: :cascade do |t|
    t.date "period", null: false
    t.string "name", null: false
    t.integer "quantity", null: false
    t.string "product_type", null: false
    t.integer "product_id", null: false
    t.integer "gross_revenue_amount_cents", default: 0, null: false
    t.string "gross_revenue_amount_currency", default: "USD", null: false
    t.integer "net_revenue_amount_cents", default: 0, null: false
    t.string "net_revenue_amount_currency", default: "USD", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["period", "name"], name: "index_iam8bit_sales_on_period_and_name", unique: true
    t.index ["product_type", "product_id"], name: "index_iam8bit_sales_on_product"
  end

  create_table "internal_merch_orders", force: :cascade do |t|
    t.integer "payout_id", null: false
    t.integer "merch_item_id", null: false
    t.integer "merch_fulfillment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["merch_fulfillment_id"], name: "index_internal_merch_orders_on_merch_fulfillment_id"
    t.index ["merch_item_id"], name: "index_internal_merch_orders_on_merch_item_id"
    t.index ["payout_id"], name: "index_internal_merch_orders_on_payout_id"
  end

  create_table "merch_fulfillments", force: :cascade do |t|
    t.integer "bandcamp_sale_id"
    t.integer "production_cost_cents", default: 0, null: false
    t.string "production_cost_currency", default: "USD", null: false
    t.date "shipped_on"
    t.integer "fulfilled_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bandcamp_sale_id"], name: "index_merch_fulfillments_on_bandcamp_sale_id"
    t.index ["fulfilled_by_id"], name: "index_merch_fulfillments_on_fulfilled_by_id"
  end

  create_table "merch_items", force: :cascade do |t|
    t.string "name", null: false
    t.string "sku", null: false
    t.string "bandcamp_url"
    t.string "artist_name"
    t.integer "list_price_cents", default: 0, null: false
    t.string "list_price_currency", default: "USD", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "variants", default: "[]", null: false
    t.boolean "private", default: false, null: false
    t.integer "external_distributor", default: 0, null: false
    t.index ["bandcamp_url", "sku"], name: "index_merch_items_on_bandcamp_url_and_sku", unique: true
  end

  create_table "patreon_sales", force: :cascade do |t|
    t.string "product_type", null: false
    t.integer "product_id", null: false
    t.date "period", null: false
    t.string "customer_name_hashed", null: false
    t.string "tier", null: false
    t.integer "net_revenue_amount_cents", default: 0, null: false
    t.string "net_revenue_amount_currency", default: "USD", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_name_hashed", "period", "product_type", "product_id"], name: "idx_on_customer_name_hashed_period_product_type_pro_57f480592f", unique: true
    t.index ["product_type", "product_id"], name: "index_patreon_sales_on_product"
  end

  create_table "payees", force: :cascade do |t|
    t.string "paypal_account"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.string "fsn", null: false
    t.boolean "is_charity", default: false, null: false
    t.boolean "opted_out_of_royalties", default: false, null: false
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

  create_table "rendered_services", force: :cascade do |t|
    t.integer "payee_id", null: false
    t.date "rendered_at"
    t.integer "type"
    t.decimal "hours", precision: 6, scale: 2
    t.text "description", null: false
    t.string "artist_name"
    t.integer "compensation_cents", default: 0, null: false
    t.string "compensation_currency", default: "USD", null: false
    t.integer "album_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["album_id"], name: "index_rendered_services_on_album_id"
    t.index ["payee_id"], name: "index_rendered_services_on_payee_id"
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
    t.integer "track_number"
    t.string "isrc"
    t.string "bandcamp_url"
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
  end

  add_foreign_key "albums_merch_items", "albums"
  add_foreign_key "albums_merch_items", "merch_items"
  add_foreign_key "artists", "payees"
  add_foreign_key "internal_merch_orders", "merch_fulfillments"
  add_foreign_key "internal_merch_orders", "merch_items"
  add_foreign_key "internal_merch_orders", "payouts"
  add_foreign_key "merch_fulfillments", "admins", column: "fulfilled_by_id"
  add_foreign_key "merch_fulfillments", "bandcamp_sales"
  add_foreign_key "payouts", "payees"
  add_foreign_key "rendered_services", "albums"
  add_foreign_key "rendered_services", "payees"
  add_foreign_key "splits", "payees"
  add_foreign_key "tracks", "albums"
end
