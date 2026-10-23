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

ActiveRecord::Schema[8.1].define(version: 2026_10_23_060320) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "listings", force: :cascade do |t|
    t.integer "member_id", null: false
    t.string "token", null: false
    t.string "title", null: false
    t.text "description"
    t.integer "price", default: 0, null: false
    t.string "category", null: false
    t.string "age_group"
    t.string "condition", default: "good", null: false
    t.string "status", default: "available", null: false
    t.string "neighborhood"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_listings_on_member_id"
    t.index ["status", "created_at"], name: "index_listings_on_status_and_created_at"
    t.index ["token"], name: "index_listings_on_token", unique: true
  end

  create_table "members", force: :cascade do |t|
    t.string "name"
    t.string "phone", null: false
    t.string "neighborhood"
    t.string "source", default: "whatsapp_group", null: false
    t.integer "invited_by_id"
    t.boolean "admin", default: false, null: false
    t.datetime "joined_at"
    t.string "sign_in_code_digest"
    t.datetime "sign_in_code_sent_at"
    t.integer "sign_in_code_attempts", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invited_by_id"], name: "index_members_on_invited_by_id"
    t.index ["phone"], name: "index_members_on_phone", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "member_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_sessions_on_member_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "listings", "members"
  add_foreign_key "members", "members", column: "invited_by_id"
  add_foreign_key "sessions", "members"
end
