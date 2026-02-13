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

ActiveRecord::Schema[8.1].define(version: 2026_02_13_161759) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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
    t.integer "consumed_timestep"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "locked_at"
    t.string "otp_backup_codes", default: [], array: true
    t.boolean "otp_required_for_login", default: false
    t.string "otp_secret"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_admins_on_unlock_token", unique: true
    t.index ["username"], name: "index_admins_on_username", unique: true
  end

  create_table "authors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_authors_on_slug", unique: true
  end

  create_table "billing_companies", force: :cascade do |t|
    t.boolean "active", default: true
    t.string "city"
    t.string "country", default: "CZ"
    t.datetime "created_at", null: false
    t.string "dic"
    t.string "fakturoid_slug"
    t.string "ico"
    t.string "name", null: false
    t.string "street"
    t.datetime "updated_at", null: false
    t.string "zip"
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
    t.string "notes"
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

  create_table "course_tags", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.bigint "tag_id", null: false
    t.index ["course_id", "tag_id"], name: "index_course_tags_on_course_id_and_tag_id", unique: true
    t.index ["course_id"], name: "index_course_tags_on_course_id"
    t.index ["tag_id"], name: "index_course_tags_on_tag_id"
  end

  create_table "courses", force: :cascade do |t|
    t.bigint "author_id"
    t.string "course_type", default: "online_course", null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "CZK", null: false
    t.text "description"
    t.string "name", null: false
    t.integer "price", default: 0, null: false
    t.string "slug"
    t.string "status", default: "draft", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_courses_on_author_id"
    t.index ["course_type"], name: "index_courses_on_course_type"
    t.index ["slug"], name: "index_courses_on_slug", unique: true
    t.index ["status"], name: "index_courses_on_status"
  end

  create_table "enrollments", force: :cascade do |t|
    t.integer "course_id", null: false
    t.datetime "created_at", null: false
    t.datetime "granted_at", null: false
    t.integer "order_id", null: false
    t.datetime "revoked_at"
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["course_id"], name: "index_enrollments_on_course_id"
    t.index ["order_id"], name: "index_enrollments_on_order_id"
    t.index ["status"], name: "index_enrollments_on_status"
    t.index ["user_id", "course_id"], name: "index_enrollments_on_user_id_and_course_id", unique: true
    t.index ["user_id"], name: "index_enrollments_on_user_id"
  end

  create_table "episodes", force: :cascade do |t|
    t.bigint "audio_asset_id"
    t.bigint "cover_asset_id"
    t.datetime "created_at", null: false
    t.integer "position", null: false
    t.datetime "published_at"
    t.string "status", default: "draft"
    t.bigint "subscription_plan_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "video_asset_id"
    t.index ["audio_asset_id"], name: "index_episodes_on_audio_asset_id"
    t.index ["cover_asset_id"], name: "index_episodes_on_cover_asset_id"
    t.index ["subscription_plan_id", "position"], name: "index_episodes_on_subscription_plan_id_and_position", unique: true
    t.index ["subscription_plan_id"], name: "index_episodes_on_subscription_plan_id"
    t.index ["video_asset_id"], name: "index_episodes_on_video_asset_id"
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "callback_priority"
    t.text "callback_queue_name"
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "discarded_at"
    t.datetime "enqueued_at"
    t.datetime "finished_at"
    t.datetime "jobs_finished_at"
    t.text "on_discard"
    t.text "on_finish"
    t.text "on_success"
    t.jsonb "serialized_properties"
    t.datetime "updated_at", null: false
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "active_job_id", null: false
    t.datetime "created_at", null: false
    t.interval "duration"
    t.text "error"
    t.text "error_backtrace", array: true
    t.integer "error_event", limit: 2
    t.datetime "finished_at"
    t.text "job_class"
    t.uuid "process_id"
    t.text "queue_name"
    t.datetime "scheduled_at"
    t.jsonb "serialized_params"
    t.datetime "updated_at", null: false
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
    t.index ["process_id", "created_at"], name: "index_good_job_executions_on_process_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "lock_type", limit: 2
    t.jsonb "state"
    t.datetime "updated_at", null: false
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "key"
    t.datetime "updated_at", null: false
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "active_job_id"
    t.uuid "batch_callback_id"
    t.uuid "batch_id"
    t.text "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "cron_at"
    t.text "cron_key"
    t.text "error"
    t.integer "error_event", limit: 2
    t.integer "executions_count"
    t.datetime "finished_at"
    t.boolean "is_discrete"
    t.text "job_class"
    t.text "labels", array: true
    t.datetime "locked_at"
    t.uuid "locked_by_id"
    t.datetime "performed_at"
    t.integer "priority"
    t.text "queue_name"
    t.uuid "retried_good_job_id"
    t.datetime "scheduled_at"
    t.jsonb "serialized_params"
    t.datetime "updated_at", null: false
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key", "created_at"], name: "index_good_jobs_on_concurrency_key_and_created_at"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at_cond", where: "(cron_key IS NOT NULL)"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at_cond", unique: true, where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at_only", where: "(finished_at IS NOT NULL)"
    t.index ["job_class"], name: "index_good_jobs_on_job_class"
    t.index ["labels"], name: "index_good_jobs_on_labels", where: "(labels IS NOT NULL)", using: :gin
    t.index ["locked_by_id"], name: "index_good_jobs_on_locked_by_id", where: "(locked_by_id IS NOT NULL)"
    t.index ["priority", "created_at"], name: "index_good_job_jobs_for_candidate_lookup", where: "(finished_at IS NULL)"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["priority", "scheduled_at"], name: "index_good_jobs_on_priority_scheduled_at_unfinished_unlocked", where: "((finished_at IS NULL) AND (locked_by_id IS NULL))"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "media_assets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "media_type", null: false
    t.text "notes"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["media_type"], name: "index_media_assets_on_media_type"
  end

  create_table "oauth_identities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.json "info", default: {}
    t.string "provider", null: false
    t.string "uid", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["email"], name: "index_oauth_identities_on_email"
    t.index ["provider", "uid"], name: "index_oauth_identities_on_provider_and_uid", unique: true
    t.index ["user_id"], name: "index_oauth_identities_on_user_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.integer "course_id"
    t.datetime "created_at", null: false
    t.string "currency", default: "CZK", null: false
    t.integer "order_id", null: false
    t.integer "quantity", default: 1, null: false
    t.bigint "subscription_plan_id"
    t.string "title_snapshot"
    t.integer "unit_amount", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_order_items_on_course_id"
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["subscription_plan_id"], name: "index_order_items_on_subscription_plan_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "billing_city"
    t.string "billing_country"
    t.string "billing_dic"
    t.string "billing_ico"
    t.string "billing_name"
    t.string "billing_street"
    t.string "billing_zip"
    t.integer "coupon_id"
    t.datetime "created_at", null: false
    t.string "currency", default: "CZK", null: false
    t.integer "discount_amount", default: 0, null: false
    t.integer "fakturoid_correction_id"
    t.string "fakturoid_correction_number"
    t.string "fakturoid_correction_url"
    t.integer "fakturoid_invoice_id"
    t.string "fakturoid_invoice_number"
    t.string "fakturoid_private_url"
    t.string "fakturoid_public_url"
    t.integer "fakturoid_subject_id"
    t.string "order_type", default: "one_time", null: false
    t.string "refund_reason"
    t.datetime "refunded_at"
    t.string "status", default: "pending", null: false
    t.string "stripe_payment_intent_id"
    t.string "stripe_session_id"
    t.bigint "subscription_id"
    t.integer "subtotal_amount", default: 0, null: false
    t.integer "total_amount", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["coupon_id"], name: "index_orders_on_coupon_id"
    t.index ["fakturoid_invoice_id"], name: "index_orders_on_fakturoid_invoice_id", unique: true
    t.index ["stripe_session_id"], name: "index_orders_on_stripe_session_id", unique: true
    t.index ["subscription_id"], name: "index_orders_on_subscription_id"
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
    t.bigint "audio_asset_id"
    t.integer "chapter_id", null: false
    t.text "content"
    t.integer "cover_asset_id"
    t.datetime "created_at", null: false
    t.boolean "is_free_preview", default: false, null: false
    t.integer "position", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "video_asset_id"
    t.index ["audio_asset_id"], name: "index_segments_on_audio_asset_id"
    t.index ["chapter_id", "position"], name: "index_segments_on_chapter_id_and_position", unique: true
    t.index ["chapter_id"], name: "index_segments_on_chapter_id"
    t.index ["cover_asset_id"], name: "index_segments_on_cover_asset_id"
    t.index ["video_asset_id"], name: "index_segments_on_video_asset_id"
  end

  create_table "subscription_plans", force: :cascade do |t|
    t.integer "annual_discount_percent", default: 0
    t.bigint "author_id", null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "CZK"
    t.integer "monthly_price", default: 0, null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.string "status", default: "draft"
    t.string "stripe_annual_price_id"
    t.string "stripe_monthly_price_id"
    t.string "stripe_product_id"
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_subscription_plans_on_author_id"
    t.index ["slug"], name: "index_subscription_plans_on_slug", unique: true
  end

  create_table "subscriptions", force: :cascade do |t|
    t.boolean "cancel_at_period_end", default: false
    t.datetime "created_at", null: false
    t.datetime "current_period_end"
    t.datetime "current_period_start"
    t.string "interval", default: "month"
    t.string "status", default: "incomplete"
    t.string "stripe_subscription_id"
    t.bigint "subscription_plan_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["stripe_subscription_id"], name: "index_subscriptions_on_stripe_subscription_id", unique: true
    t.index ["subscription_plan_id"], name: "index_subscriptions_on_subscription_plan_id"
    t.index ["user_id", "subscription_plan_id"], name: "index_subscriptions_on_user_id_and_subscription_plan_id", unique: true
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
    t.index ["slug"], name: "index_tags_on_slug", unique: true
  end

  create_table "user_sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "last_active_at"
    t.string "session_token", null: false
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["last_active_at"], name: "index_user_sessions_on_last_active_at"
    t.index ["session_token"], name: "index_user_sessions_on_session_token", unique: true
    t.index ["user_id"], name: "index_user_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "avatar_url"
    t.string "billing_city"
    t.string "billing_country", default: "CZ"
    t.string "billing_dic"
    t.string "billing_ico"
    t.string "billing_name"
    t.string "billing_street"
    t.string "billing_zip"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "provider"
    t.string "stripe_customer_id"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["stripe_customer_id"], name: "index_users_on_stripe_customer_id", unique: true
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
  add_foreign_key "course_tags", "courses"
  add_foreign_key "course_tags", "tags"
  add_foreign_key "courses", "authors"
  add_foreign_key "enrollments", "courses"
  add_foreign_key "enrollments", "orders"
  add_foreign_key "enrollments", "users"
  add_foreign_key "episodes", "media_assets", column: "audio_asset_id"
  add_foreign_key "episodes", "subscription_plans"
  add_foreign_key "oauth_identities", "users"
  add_foreign_key "order_items", "courses"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "subscription_plans"
  add_foreign_key "orders", "coupons"
  add_foreign_key "orders", "subscriptions"
  add_foreign_key "orders", "users"
  add_foreign_key "segment_completions", "segments"
  add_foreign_key "segment_completions", "users"
  add_foreign_key "segments", "chapters"
  add_foreign_key "segments", "media_assets", column: "audio_asset_id"
  add_foreign_key "segments", "media_assets", column: "cover_asset_id"
  add_foreign_key "segments", "media_assets", column: "video_asset_id"
  add_foreign_key "subscription_plans", "authors"
  add_foreign_key "subscriptions", "subscription_plans"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "user_sessions", "users"
end
