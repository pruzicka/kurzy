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

ActiveRecord::Schema[8.1].define(version: 2026_02_09_162000) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admins", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
    t.index ["username"], name: "index_admins_on_username", unique: true
  end

  create_table "cart_items", force: :cascade do |t|
    t.integer "cart_id", null: false
    t.integer "course_id", null: false
    t.datetime "created_at", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id", "course_id"], name: "index_cart_items_on_cart_id_and_course_id", unique: true
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["course_id"], name: "index_cart_items_on_course_id"
  end

  create_table "carts", force: :cascade do |t|
    t.integer "coupon_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["coupon_id"], name: "index_carts_on_coupon_id"
    t.index ["user_id"], name: "index_carts_on_user_id", unique: true
  end

  create_table "chapters", force: :cascade do |t|
    t.integer "course_id", null: false
    t.datetime "created_at", null: false
    t.boolean "is_mandatory", default: false, null: false
    t.integer "position", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id", "position"], name: "index_chapters_on_course_id_and_position", unique: true
    t.index ["course_id"], name: "index_chapters_on_course_id"
  end

  create_table "coupon_redemptions", force: :cascade do |t|
    t.integer "coupon_id", null: false
    t.datetime "created_at", null: false
    t.integer "order_id", null: false
    t.datetime "redeemed_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["coupon_id"], name: "index_coupon_redemptions_on_coupon_id"
    t.index ["order_id"], name: "index_coupon_redemptions_on_order_id", unique: true
    t.index ["user_id"], name: "index_coupon_redemptions_on_user_id"
  end

  create_table "coupons", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "currency"
    t.string "discount_type", null: false
    t.datetime "ends_at"
    t.integer "max_redemptions"
    t.string "name"
    t.integer "redemptions_count", default: 0, null: false
    t.datetime "starts_at"
    t.datetime "updated_at", null: false
    t.integer "value", null: false
    t.index ["active"], name: "index_coupons_on_active"
    t.index ["code"], name: "index_coupons_on_code", unique: true
  end

  create_table "course_progresses", force: :cascade do |t|
    t.integer "course_id", null: false
    t.datetime "created_at", null: false
    t.integer "last_segment_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["course_id"], name: "index_course_progresses_on_course_id"
    t.index ["last_segment_id"], name: "index_course_progresses_on_last_segment_id"
    t.index ["user_id", "course_id"], name: "index_course_progresses_on_user_id_and_course_id", unique: true
    t.index ["user_id"], name: "index_course_progresses_on_user_id"
  end

  create_table "courses", force: :cascade do |t|
    t.string "course_type", default: "online_course", null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "CZK", null: false
    t.text "description"
    t.string "name", null: false
    t.integer "price", default: 0, null: false
    t.string "slug"
    t.string "status", default: "draft", null: false
    t.datetime "updated_at", null: false
    t.index ["course_type"], name: "index_courses_on_course_type"
    t.index ["slug"], name: "index_courses_on_slug", unique: true
    t.index ["status"], name: "index_courses_on_status"
  end

  create_table "enrollments", force: :cascade do |t|
    t.integer "course_id", null: false
    t.datetime "created_at", null: false
    t.datetime "granted_at", null: false
    t.integer "order_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["course_id"], name: "index_enrollments_on_course_id"
    t.index ["order_id"], name: "index_enrollments_on_order_id"
    t.index ["user_id", "course_id"], name: "index_enrollments_on_user_id_and_course_id", unique: true
    t.index ["user_id"], name: "index_enrollments_on_user_id"
  end

  create_table "media_assets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "media_type", null: false
    t.text "notes"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["media_type"], name: "index_media_assets_on_media_type"
  end

  create_table "order_items", force: :cascade do |t|
    t.integer "course_id", null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "CZK", null: false
    t.integer "order_id", null: false
    t.integer "quantity", default: 1, null: false
    t.integer "unit_amount", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_order_items_on_course_id"
    t.index ["order_id"], name: "index_order_items_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "coupon_id"
    t.datetime "created_at", null: false
    t.string "currency", default: "CZK", null: false
    t.integer "discount_amount", default: 0, null: false
    t.string "status", default: "pending", null: false
    t.string "stripe_payment_intent_id"
    t.string "stripe_session_id"
    t.integer "subtotal_amount", default: 0, null: false
    t.integer "total_amount", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["coupon_id"], name: "index_orders_on_coupon_id"
    t.index ["stripe_session_id"], name: "index_orders_on_stripe_session_id", unique: true
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "segment_completions", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.integer "segment_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["segment_id"], name: "index_segment_completions_on_segment_id"
    t.index ["user_id", "segment_id"], name: "index_segment_completions_on_user_id_and_segment_id", unique: true
    t.index ["user_id"], name: "index_segment_completions_on_user_id"
  end

  create_table "segments", force: :cascade do |t|
    t.integer "chapter_id", null: false
    t.text "content"
    t.integer "cover_asset_id"
    t.datetime "created_at", null: false
    t.integer "position", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "video_asset_id"
    t.index ["chapter_id", "position"], name: "index_segments_on_chapter_id_and_position", unique: true
    t.index ["chapter_id"], name: "index_segments_on_chapter_id"
    t.index ["cover_asset_id"], name: "index_segments_on_cover_asset_id"
    t.index ["video_asset_id"], name: "index_segments_on_video_asset_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "provider", null: false
    t.string "uid", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "courses"
  add_foreign_key "carts", "coupons"
  add_foreign_key "carts", "users"
  add_foreign_key "chapters", "courses"
  add_foreign_key "coupon_redemptions", "coupons"
  add_foreign_key "coupon_redemptions", "orders"
  add_foreign_key "coupon_redemptions", "users"
  add_foreign_key "course_progresses", "courses"
  add_foreign_key "course_progresses", "segments", column: "last_segment_id"
  add_foreign_key "course_progresses", "users"
  add_foreign_key "enrollments", "courses"
  add_foreign_key "enrollments", "orders"
  add_foreign_key "enrollments", "users"
  add_foreign_key "order_items", "courses"
  add_foreign_key "order_items", "orders"
  add_foreign_key "orders", "coupons"
  add_foreign_key "orders", "users"
  add_foreign_key "segment_completions", "segments"
  add_foreign_key "segment_completions", "users"
  add_foreign_key "segments", "chapters"
  add_foreign_key "segments", "media_assets", column: "cover_asset_id"
  add_foreign_key "segments", "media_assets", column: "video_asset_id"
end
