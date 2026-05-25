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

ActiveRecord::Schema[8.1].define(version: 2026_05_25_102502) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "account_invitations", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.bigint "invited_by_id"
    t.string "name", null: false
    t.jsonb "roles", default: {}, null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "email"], name: "index_account_invitations_on_account_id_and_email", unique: true
    t.index ["invited_by_id"], name: "index_account_invitations_on_invited_by_id"
    t.index ["token"], name: "index_account_invitations_on_token", unique: true
  end

  create_table "account_users", force: :cascade do |t|
    t.bigint "account_id"
    t.datetime "created_at", null: false
    t.integer "relationship_to_child", default: 0
    t.jsonb "roles", default: {}, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["account_id", "user_id"], name: "index_account_users_on_account_id_and_user_id", unique: true
  end

  create_table "accounts", force: :cascade do |t|
    t.integer "account_users_count", default: 0
    t.string "billing_email"
    t.datetime "created_at", null: false
    t.string "domain"
    t.text "extra_billing_info"
    t.string "name", null: false
    t.bigint "owner_id"
    t.boolean "personal", default: false
    t.string "subdomain"
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_accounts_on_owner_id"
  end

  create_table "action_text_embeds", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "fields"
    t.datetime "updated_at", null: false
    t.string "url"
  end

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
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
    t.datetime "created_at", precision: nil, null: false
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

  create_table "age_band_questionnaires", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "development_area_id", null: false
    t.string "label", null: false
    t.integer "max_age_months", null: false
    t.integer "min_age_months", null: false
    t.integer "position", default: 0, null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "version", default: 1, null: false
    t.index ["development_area_id", "min_age_months"], name: "idx_questionnaires_area_age", unique: true
    t.index ["development_area_id"], name: "index_age_band_questionnaires_on_development_area_id"
    t.index ["min_age_months", "max_age_months"], name: "idx_on_min_age_months_max_age_months_817a34338d"
    t.index ["version"], name: "index_age_band_questionnaires_on_version"
  end

  create_table "announcements", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "kind"
    t.datetime "published_at", precision: nil
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "api_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", precision: nil
    t.datetime "last_used_at", precision: nil
    t.jsonb "metadata"
    t.string "name"
    t.string "token"
    t.boolean "transient", default: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["token"], name: "index_api_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_api_tokens_on_user_id"
  end

  create_table "archive_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "for_content_type", null: false
    t.string "name", null: false
    t.integer "position", default: 0
    t.datetime "updated_at", null: false
    t.index ["for_content_type", "name"], name: "index_archive_categories_on_for_content_type_and_name", unique: true
  end

  create_table "archive_contents", force: :cascade do |t|
    t.string "author"
    t.text "benefits", default: [], null: false, array: true
    t.string "category"
    t.integer "content_type", default: 0, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "duration_minutes"
    t.string "illustrator"
    t.string "isbn"
    t.string "materials"
    t.integer "max_age_months", default: 36
    t.integer "min_age_months", default: 0
    t.integer "position", default: 0
    t.integer "publication_year"
    t.boolean "published", default: false
    t.datetime "published_at"
    t.string "publisher"
    t.text "recommendations", default: [], null: false, array: true
    t.string "slug", null: false
    t.boolean "specialist", default: false, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_archive_contents_on_category"
    t.index ["content_type", "published"], name: "index_archive_contents_on_content_type_and_published"
    t.index ["content_type", "specialist", "published"], name: "idx_on_content_type_specialist_published_6d174017a2"
    t.index ["content_type"], name: "index_archive_contents_on_content_type"
    t.index ["min_age_months", "max_age_months"], name: "index_archive_contents_on_min_age_months_and_max_age_months"
    t.index ["position"], name: "index_archive_contents_on_position"
    t.index ["slug"], name: "index_archive_contents_on_slug", unique: true
  end

  create_table "archive_favorites", force: :cascade do |t|
    t.bigint "archive_content_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["archive_content_id"], name: "index_archive_favorites_on_archive_content_id"
    t.index ["user_id", "archive_content_id"], name: "index_archive_favorites_on_user_id_and_archive_content_id", unique: true
    t.index ["user_id"], name: "index_archive_favorites_on_user_id"
  end

  create_table "archive_page_sections", force: :cascade do |t|
    t.bigint "archive_section_id", null: false
    t.datetime "created_at", null: false
    t.string "display_label_override"
    t.integer "limit_override"
    t.string "page_identifier", null: false
    t.integer "position", default: 0
    t.datetime "updated_at", null: false
    t.index ["archive_section_id"], name: "index_archive_page_sections_on_archive_section_id"
    t.index ["page_identifier", "archive_section_id"], name: "idx_page_sections_on_page_and_section", unique: true
    t.index ["page_identifier", "position"], name: "idx_page_sections_on_page_and_position"
  end

  create_table "archive_sections", force: :cascade do |t|
    t.boolean "active", default: true
    t.string "card_partial", null: false
    t.string "content_types", null: false
    t.datetime "created_at", null: false
    t.integer "default_limit", default: 4
    t.string "filter_type"
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_archive_sections_on_slug", unique: true
  end

  create_table "beta_feedbacks", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.text "admin_notes"
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.integer "feedback_type", default: 0, null: false
    t.jsonb "metadata", default: {}
    t.string "page_url", null: false
    t.string "section", null: false
    t.integer "severity", default: 0
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["account_id"], name: "index_beta_feedbacks_on_account_id"
    t.index ["feedback_type"], name: "index_beta_feedbacks_on_feedback_type"
    t.index ["section"], name: "index_beta_feedbacks_on_section"
    t.index ["status"], name: "index_beta_feedbacks_on_status"
    t.index ["user_id"], name: "index_beta_feedbacks_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "icon_key"
    t.string "name", null: false
    t.integer "position", default: 0
    t.boolean "published", default: true
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
    t.index ["position"], name: "index_categories_on_position"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "child_health_profiles", force: :cascade do |t|
    t.decimal "average_sleep_hours", precision: 4, scale: 1
    t.jsonb "birth_complications", default: []
    t.decimal "birth_height_cm", precision: 4, scale: 1
    t.integer "birth_weight_grams"
    t.integer "birth_weight_under_1500"
    t.bigint "child_id", null: false
    t.date "complementary_feeding_start_date"
    t.datetime "created_at", null: false
    t.integer "current_feeding_type"
    t.text "feeding_difficulties"
    t.integer "floor_play_minutes_per_day"
    t.integer "gestational_age_category"
    t.integer "hearing_screening_result"
    t.integer "hospitalized_after_birth"
    t.boolean "is_multiple_birth", default: false
    t.text "main_foods_introduced"
    t.integer "pregnancy_type"
    t.integer "required_oxygen_ventilation"
    t.jsonb "scheduled_followups", default: []
    t.jsonb "sleep_quality_issues", default: []
    t.boolean "started_complementary_feeding", default: false
    t.datetime "updated_at", null: false
    t.integer "vision_screening_result"
    t.index ["child_id"], name: "index_child_health_profiles_on_child_id", unique: true
  end

  create_table "children", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.boolean "active", default: true
    t.date "birth_date", null: false
    t.datetime "created_at", null: false
    t.integer "gestational_days"
    t.integer "gestational_weeks"
    t.string "name"
    t.string "nickname"
    t.text "notes"
    t.integer "sex", default: 0
    t.datetime "updated_at", null: false
    t.index ["account_id", "active"], name: "index_children_on_account_id_and_active"
    t.index ["account_id"], name: "index_children_on_account_id"
  end

  create_table "connected_accounts", force: :cascade do |t|
    t.string "access_token"
    t.string "access_token_secret"
    t.jsonb "auth"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "expires_at", precision: nil
    t.bigint "owner_id"
    t.string "owner_type"
    t.string "provider"
    t.string "refresh_token"
    t.string "uid"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["owner_id", "owner_type"], name: "index_connected_accounts_on_owner_id_and_owner_type"
  end

  create_table "dashboard_stage_contents", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.string "kind", null: false
    t.string "label", null: false
    t.integer "max_age_months"
    t.integer "max_age_weeks"
    t.integer "min_age_months"
    t.integer "min_age_weeks"
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["kind", "min_age_months", "max_age_months"], name: "idx_dashboard_stage_contents_monthly"
    t.index ["kind", "min_age_weeks", "max_age_weeks"], name: "idx_dashboard_stage_contents_weekly"
  end

  create_table "development_areas", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.string "icon"
    t.string "illustration_key"
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["illustration_key"], name: "index_development_areas_on_illustration_key", unique: true
    t.index ["position"], name: "index_development_areas_on_position"
    t.index ["slug"], name: "index_development_areas_on_slug", unique: true
  end

  create_table "family_profiles", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "country"
    t.datetime "created_at", null: false
    t.integer "family_structure", default: 0
    t.boolean "has_hereditary_conditions"
    t.jsonb "hereditary_conditions", default: []
    t.integer "languages_spoken_at_home", default: 1
    t.string "mother_tongue"
    t.string "nationality"
    t.integer "number_of_children", default: 1
    t.jsonb "primary_caregivers", default: []
    t.integer "two_parents_type"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_family_profiles_on_account_id", unique: true
  end

  create_table "growth_phases", force: :cascade do |t|
    t.string "carousel_label"
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.string "illustration_key"
    t.integer "max_age_months", default: 36, null: false
    t.integer "min_age_months", default: 0, null: false
    t.integer "position", default: 0
    t.string "timeline_title"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["min_age_months", "max_age_months"], name: "index_growth_phases_on_min_age_months_and_max_age_months"
  end

  create_table "inbound_webhooks", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
  end

  create_table "measurements", force: :cascade do |t|
    t.bigint "child_id", null: false
    t.datetime "created_at", null: false
    t.datetime "measured_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.integer "measurement_type", null: false
    t.text "notes"
    t.integer "percentile"
    t.datetime "updated_at", null: false
    t.decimal "value", precision: 8, scale: 2, null: false
    t.index ["child_id", "measurement_type", "measured_at"], name: "idx_measurements_child_type_date"
    t.index ["child_id", "measurement_type", "measured_at"], name: "idx_measurements_child_type_date_desc", order: { measured_at: :desc }
    t.index ["child_id"], name: "index_measurements_on_child_id"
  end

  create_table "noticed_events", force: :cascade do |t|
    t.bigint "account_id"
    t.datetime "created_at", null: false
    t.integer "notifications_count"
    t.jsonb "params"
    t.bigint "record_id"
    t.string "record_type"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_noticed_events_on_account_id"
    t.index ["record_type", "record_id"], name: "index_noticed_events_on_record"
  end

  create_table "noticed_notifications", force: :cascade do |t|
    t.bigint "account_id"
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.datetime "read_at", precision: nil
    t.bigint "recipient_id", null: false
    t.string "recipient_type", null: false
    t.datetime "seen_at", precision: nil
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_noticed_notifications_on_account_id"
    t.index ["event_id"], name: "index_noticed_notifications_on_event_id"
    t.index ["recipient_type", "recipient_id"], name: "index_noticed_notifications_on_recipient"
  end

  create_table "notification_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "platform", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_notification_tokens_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "interacted_at", precision: nil
    t.jsonb "params"
    t.datetime "read_at", precision: nil
    t.bigint "recipient_id", null: false
    t.string "recipient_type", null: false
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_notifications_on_account_id"
    t.index ["recipient_type", "recipient_id"], name: "index_notifications_on_recipient_type_and_recipient_id"
  end

  create_table "pay_charges", force: :cascade do |t|
    t.integer "amount", null: false
    t.integer "amount_refunded"
    t.integer "application_fee_amount"
    t.datetime "created_at", precision: nil, null: false
    t.string "currency"
    t.bigint "customer_id"
    t.jsonb "data"
    t.jsonb "metadata"
    t.jsonb "object"
    t.string "processor_id", null: false
    t.string "stripe_account"
    t.integer "subscription_id"
    t.string "type"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["customer_id", "processor_id"], name: "index_pay_charges_on_customer_id_and_processor_id", unique: true
  end

  create_table "pay_customers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "data"
    t.boolean "default"
    t.datetime "deleted_at", precision: nil
    t.jsonb "object"
    t.bigint "owner_id"
    t.string "owner_type"
    t.string "processor"
    t.string "processor_id"
    t.string "stripe_account"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id", "deleted_at"], name: "customer_owner_processor_index"
    t.index ["processor", "processor_id"], name: "index_pay_customers_on_processor_and_processor_id"
  end

  create_table "pay_merchants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "data"
    t.boolean "default"
    t.bigint "owner_id"
    t.string "owner_type"
    t.string "processor"
    t.string "processor_id"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id", "processor"], name: "index_pay_merchants_on_owner_type_and_owner_id_and_processor"
  end

  create_table "pay_payment_methods", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "customer_id"
    t.jsonb "data"
    t.boolean "default"
    t.string "payment_method_type"
    t.string "processor_id"
    t.string "stripe_account"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["customer_id", "processor_id"], name: "index_pay_payment_methods_on_customer_id_and_processor_id", unique: true
  end

  create_table "pay_subscriptions", id: :serial, force: :cascade do |t|
    t.decimal "application_fee_percent", precision: 8, scale: 2
    t.datetime "created_at", precision: nil
    t.datetime "current_period_end"
    t.datetime "current_period_start"
    t.bigint "customer_id"
    t.jsonb "data"
    t.datetime "ends_at", precision: nil
    t.jsonb "metadata"
    t.boolean "metered"
    t.string "name", null: false
    t.jsonb "object"
    t.string "pause_behavior"
    t.datetime "pause_resumes_at"
    t.datetime "pause_starts_at"
    t.string "payment_method_id"
    t.string "processor_id", null: false
    t.string "processor_plan", null: false
    t.integer "quantity", default: 1, null: false
    t.string "status"
    t.string "stripe_account"
    t.datetime "trial_ends_at", precision: nil
    t.string "type"
    t.datetime "updated_at", precision: nil
    t.index ["customer_id", "processor_id"], name: "index_pay_subscriptions_on_customer_id_and_processor_id", unique: true
    t.index ["metered"], name: "index_pay_subscriptions_on_metered"
    t.index ["pause_starts_at"], name: "index_pay_subscriptions_on_pause_starts_at"
  end

  create_table "pay_webhooks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "event"
    t.string "event_type"
    t.string "processor"
    t.datetime "updated_at", null: false
  end

  create_table "pediatrician_questions", force: :cascade do |t|
    t.text "body", null: false
    t.bigint "child_id", null: false
    t.datetime "created_at", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["child_id"], name: "index_pediatrician_questions_on_child_id"
  end

  create_table "plans", force: :cascade do |t|
    t.integer "amount", default: 0, null: false
    t.string "braintree_id"
    t.boolean "charge_per_unit"
    t.string "contact_url"
    t.datetime "created_at", precision: nil, null: false
    t.string "currency"
    t.string "description"
    t.jsonb "details"
    t.string "fake_processor_id"
    t.boolean "hidden"
    t.string "interval", null: false
    t.integer "interval_count", default: 1
    t.string "lemon_squeezy_id"
    t.string "name", null: false
    t.string "paddle_billing_id"
    t.string "paddle_classic_id"
    t.string "stripe_id"
    t.integer "trial_period_days", default: 0
    t.string "unit_label"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "question_responses", force: :cascade do |t|
    t.integer "answer", default: 0, null: false
    t.datetime "created_at", null: false
    t.boolean "inherited", default: false, null: false
    t.text "notes"
    t.bigint "question_id", null: false
    t.bigint "questionnaire_session_id", null: false
    t.datetime "updated_at", null: false
    t.index ["inherited"], name: "index_question_responses_on_inherited"
    t.index ["question_id"], name: "index_question_responses_on_question_id"
    t.index ["questionnaire_session_id", "question_id"], name: "idx_responses_session_question", unique: true
    t.index ["questionnaire_session_id"], name: "index_question_responses_on_questionnaire_session_id"
  end

  create_table "questionnaire_sessions", force: :cascade do |t|
    t.bigint "age_band_questionnaire_id", null: false
    t.integer "child_age_months"
    t.bigint "child_id", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.text "notes"
    t.integer "questionnaire_version"
    t.datetime "started_at"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["age_band_questionnaire_id"], name: "index_questionnaire_sessions_on_age_band_questionnaire_id"
    t.index ["child_id", "age_band_questionnaire_id", "created_at"], name: "idx_sessions_child_questionnaire_time"
    t.index ["child_id", "status"], name: "index_questionnaire_sessions_on_child_id_and_status"
    t.index ["child_id"], name: "index_questionnaire_sessions_on_child_id"
    t.index ["questionnaire_version"], name: "index_questionnaire_sessions_on_questionnaire_version"
  end

  create_table "questions", force: :cascade do |t|
    t.boolean "active", default: true
    t.bigint "age_band_questionnaire_id", null: false
    t.string "content_key"
    t.datetime "created_at", null: false
    t.text "help_text"
    t.string "illustration_key"
    t.integer "position", default: 0, null: false
    t.text "prompt", null: false
    t.string "uncertain_label"
    t.datetime "updated_at", null: false
    t.index ["age_band_questionnaire_id", "position"], name: "index_questions_on_age_band_questionnaire_id_and_position"
    t.index ["age_band_questionnaire_id"], name: "index_questions_on_age_band_questionnaire_id"
    t.index ["content_key"], name: "index_questions_on_content_key"
    t.index ["illustration_key"], name: "index_questions_on_illustration_key", unique: true
  end

  create_table "shuby_chats", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "child_id"
    t.datetime "created_at", null: false
    t.string "model", default: "gpt-5.4-mini", null: false
    t.string "previous_response_id"
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["account_id", "user_id"], name: "index_shuby_chats_on_account_id_and_user_id"
    t.index ["account_id"], name: "index_shuby_chats_on_account_id"
    t.index ["child_id"], name: "index_shuby_chats_on_child_id"
    t.index ["created_at"], name: "index_shuby_chats_on_created_at"
    t.index ["user_id"], name: "index_shuby_chats_on_user_id"
  end

  create_table "shuby_messages", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.integer "input_tokens"
    t.string "model_id"
    t.integer "output_tokens"
    t.string "role", null: false
    t.bigint "shuby_chat_id", null: false
    t.bigint "shuby_tool_call_id"
    t.datetime "updated_at", null: false
    t.index ["role"], name: "index_shuby_messages_on_role"
    t.index ["shuby_chat_id"], name: "index_shuby_messages_on_shuby_chat_id"
    t.index ["shuby_tool_call_id"], name: "index_shuby_messages_on_shuby_tool_call_id"
  end

  create_table "shuby_tool_calls", force: :cascade do |t|
    t.json "arguments", default: {}
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.json "result"
    t.bigint "shuby_message_id", null: false
    t.string "tool_call_id", null: false
    t.datetime "updated_at", null: false
    t.index ["shuby_message_id"], name: "index_shuby_tool_calls_on_shuby_message_id"
    t.index ["tool_call_id"], name: "index_shuby_tool_calls_on_tool_call_id"
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.binary "channel", null: false
    t.bigint "channel_hash", null: false
    t.datetime "created_at", null: false
    t.binary "payload", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.bigint "job_id", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.bigint "supervisor_id"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1, null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "stimulation_activities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.integer "month", null: false
    t.integer "position", default: 0
    t.datetime "updated_at", null: false
    t.index ["month", "position"], name: "index_stimulation_activities_on_month_and_position"
  end

  create_table "timeline_periods", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "growth_phase_id", null: false
    t.decimal "head_circ_max_cm"
    t.decimal "head_circ_min_cm"
    t.decimal "height_max_cm"
    t.decimal "height_min_cm"
    t.integer "period_number"
    t.string "period_type"
    t.integer "position"
    t.string "title"
    t.datetime "updated_at", null: false
    t.decimal "weight_max_kg"
    t.decimal "weight_min_kg"
    t.index ["growth_phase_id"], name: "index_timeline_periods_on_growth_phase_id"
  end

  create_table "timeline_stage_contents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.string "pill_key", null: false
    t.integer "position", default: 0, null: false
    t.text "suggestions"
    t.datetime "updated_at", null: false
    t.index ["pill_key"], name: "index_timeline_stage_contents_on_pill_key", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "accepted_informed_consent_at"
    t.datetime "accepted_privacy_at", precision: nil
    t.datetime "accepted_terms_at", precision: nil
    t.boolean "admin"
    t.datetime "announcements_read_at", precision: nil
    t.boolean "beta_tester", default: false
    t.datetime "confirmation_sent_at", precision: nil
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.datetime "invitation_accepted_at", precision: nil
    t.datetime "invitation_created_at", precision: nil
    t.integer "invitation_limit"
    t.datetime "invitation_sent_at", precision: nil
    t.string "invitation_token"
    t.integer "invitations_count", default: 0
    t.bigint "invited_by_id"
    t.string "invited_by_type"
    t.string "last_name"
    t.integer "last_otp_timestep"
    t.integer "monthly_messages_count", default: 0, null: false
    t.datetime "monthly_messages_reset_at"
    t.virtual "name", type: :string, as: "(((first_name)::text || ' '::text) || (COALESCE(last_name, ''::character varying))::text)", stored: true
    t.datetime "onboarding_completed_at"
    t.integer "onboarding_step", default: 0
    t.text "otp_backup_codes"
    t.boolean "otp_required_for_login"
    t.string "otp_secret"
    t.jsonb "preferences"
    t.string "preferred_language"
    t.datetime "remember_created_at", precision: nil
    t.datetime "research_consent_anonymized_at"
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.string "time_zone"
    t.string "unconfirmed_email"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["onboarding_completed_at"], name: "index_users_on_onboarding_completed_at"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "warning_signs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.integer "month", null: false
    t.integer "position", default: 0
    t.datetime "updated_at", null: false
    t.index ["month", "position"], name: "index_warning_signs_on_month_and_position"
  end

  add_foreign_key "account_invitations", "accounts"
  add_foreign_key "account_invitations", "users", column: "invited_by_id"
  add_foreign_key "account_users", "accounts"
  add_foreign_key "account_users", "users"
  add_foreign_key "accounts", "users", column: "owner_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "age_band_questionnaires", "development_areas"
  add_foreign_key "api_tokens", "users"
  add_foreign_key "archive_favorites", "archive_contents"
  add_foreign_key "archive_favorites", "users"
  add_foreign_key "archive_page_sections", "archive_sections"
  add_foreign_key "beta_feedbacks", "accounts"
  add_foreign_key "beta_feedbacks", "users"
  add_foreign_key "child_health_profiles", "children"
  add_foreign_key "children", "accounts"
  add_foreign_key "family_profiles", "accounts"
  add_foreign_key "measurements", "children"
  add_foreign_key "pay_charges", "pay_customers", column: "customer_id"
  add_foreign_key "pay_payment_methods", "pay_customers", column: "customer_id"
  add_foreign_key "pay_subscriptions", "pay_customers", column: "customer_id"
  add_foreign_key "pediatrician_questions", "children"
  add_foreign_key "question_responses", "questionnaire_sessions"
  add_foreign_key "question_responses", "questions"
  add_foreign_key "questionnaire_sessions", "age_band_questionnaires"
  add_foreign_key "questionnaire_sessions", "children"
  add_foreign_key "questions", "age_band_questionnaires"
  add_foreign_key "shuby_chats", "accounts"
  add_foreign_key "shuby_chats", "children"
  add_foreign_key "shuby_chats", "users"
  add_foreign_key "shuby_messages", "shuby_chats"
  add_foreign_key "shuby_messages", "shuby_tool_calls"
  add_foreign_key "shuby_tool_calls", "shuby_messages"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "timeline_periods", "growth_phases"
end
