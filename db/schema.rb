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

ActiveRecord::Schema.define(version: 2021_03_07_230538) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "fuzzystrmatch"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

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
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "character_items", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.bigint "item_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["character_id", "item_id"], name: "index_character_items_on_character_id_and_item_id", unique: true
    t.index ["character_id"], name: "index_character_items_on_character_id"
    t.index ["item_id"], name: "index_character_items_on_item_id"
  end

  create_table "character_traits", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.bigint "trait_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["character_id", "trait_id"], name: "index_character_traits_on_character_id_and_trait_id", unique: true
    t.index ["character_id"], name: "index_character_traits_on_character_id"
    t.index ["trait_id"], name: "index_character_traits_on_trait_id"
  end

  create_table "characters", force: :cascade do |t|
    t.citext "name", null: false
    t.bigint "universe_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_characters_on_discarded_at"
    t.index ["name", "universe_id"], name: "index_characters_on_name_and_universe_id", unique: true
    t.index ["universe_id"], name: "index_characters_on_universe_id"
  end

  create_table "collaborations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "universe_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["universe_id"], name: "index_collaborations_on_universe_id"
    t.index ["user_id", "universe_id"], name: "index_collaborations_on_user_id_and_universe_id", unique: true
    t.index ["user_id"], name: "index_collaborations_on_user_id"
  end

  create_table "facts", force: :cascade do |t|
    t.text "content", null: false
    t.string "fact_type", null: false
    t.bigint "character_id"
    t.bigint "location_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["character_id"], name: "index_facts_on_character_id"
    t.index ["location_id"], name: "index_facts_on_location_id"
  end

  create_table "image_tags", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.bigint "image_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["character_id", "image_id"], name: "index_image_tags_on_character_id_and_image_id", unique: true
    t.index ["character_id"], name: "index_image_tags_on_character_id"
    t.index ["image_id"], name: "index_image_tags_on_image_id"
  end

  create_table "images", force: :cascade do |t|
    t.text "caption", default: "", null: false
    t.boolean "avatar", default: false, null: false
    t.bigint "universe_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "universe_avatar"
    t.index ["universe_id"], name: "index_images_on_universe_id"
  end

  create_table "items", force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_items_on_name", unique: true
  end

  create_table "locations", force: :cascade do |t|
    t.citext "name", null: false
    t.bigint "universe_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name", "universe_id"], name: "index_locations_on_name_and_universe_id", unique: true
    t.index ["universe_id"], name: "index_locations_on_universe_id"
  end

  create_table "mutual_relationships", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text "content"
    t.string "searchable_type"
    t.bigint "searchable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id"
  end

  create_table "relationships", force: :cascade do |t|
    t.bigint "mutual_relationship_id", null: false
    t.bigint "originating_character_id", null: false
    t.bigint "target_character_id", null: false
    t.citext "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["mutual_relationship_id"], name: "index_relationships_on_mutual_relationship_id"
    t.index ["originating_character_id", "target_character_id", "name"], name: "relationships_unique_constraint", unique: true
    t.index ["originating_character_id"], name: "index_relationships_on_originating_character_id"
    t.index ["target_character_id"], name: "index_relationships_on_target_character_id"
    t.check_constraint "originating_character_id <> target_character_id", name: "relationships_no_self_relationships"
  end

  create_table "traits", force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_traits_on_name", unique: true
  end

  create_table "universes", force: :cascade do |t|
    t.citext "name", null: false
    t.bigint "owner_id", null: false
    t.datetime "discarded_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["discarded_at"], name: "index_universes_on_discarded_at"
    t.index ["name"], name: "index_universes_on_name", unique: true
    t.index ["owner_id"], name: "index_universes_on_owner_id"
  end

  create_table "users", force: :cascade do |t|
    t.citext "display_name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["display_name"], name: "index_users_on_display_name", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "character_items", "characters"
  add_foreign_key "character_items", "items"
  add_foreign_key "character_traits", "characters"
  add_foreign_key "character_traits", "traits"
  add_foreign_key "characters", "universes"
  add_foreign_key "facts", "characters"
  add_foreign_key "facts", "locations"
  add_foreign_key "locations", "universes"
  add_foreign_key "relationships", "characters", column: "originating_character_id"
  add_foreign_key "relationships", "characters", column: "target_character_id"
  add_foreign_key "universes", "users", column: "owner_id"
end
