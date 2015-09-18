# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150903174313) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attribute_mappers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",               default: 0, null: false
    t.integer  "attempts",               default: 0, null: false
    t.text     "handler",                            null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "export_logs", force: :cascade do |t|
    t.integer  "connection_id",               null: false
    t.string   "connection_type", limit: 255, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "export_logs", ["connection_id", "connection_type"], name: "index_export_logs_on_connection_id_and_connection_type", using: :btree

  create_table "field_mappings", force: :cascade do |t|
    t.string   "integration_field_name", limit: 255, null: false
    t.string   "namely_field_name",      limit: 255
    t.integer  "attribute_mapper_id",                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "integration_field_id",   limit: 255, null: false
  end

  add_index "field_mappings", ["attribute_mapper_id"], name: "index_field_mappings_on_attribute_mapper_id", using: :btree

  create_table "greenhouse_connections", force: :cascade do |t|
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "secret_key",          limit: 255
    t.string   "name",                limit: 255
    t.boolean  "found_namely_field",              default: false, null: false
    t.integer  "installation_id",                                 null: false
    t.integer  "attribute_mapper_id"
  end

  add_index "greenhouse_connections", ["installation_id"], name: "index_greenhouse_connections_on_installation_id", using: :btree

  create_table "icims_connections", force: :cascade do |t|
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "username",           limit: 255
    t.integer  "customer_id"
    t.boolean  "found_namely_field",             default: false, null: false
    t.string   "key",                limit: 255
    t.string   "api_key",            limit: 255
    t.integer  "installation_id",                                null: false
  end

  add_index "icims_connections", ["installation_id"], name: "index_icims_connections_on_installation_id", using: :btree

  create_table "installations", force: :cascade do |t|
    t.string   "subdomain",  limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "installations", ["subdomain"], name: "index_installations_on_subdomain", unique: true, using: :btree

  create_table "jobvite_connections", force: :cascade do |t|
    t.string   "api_key",              limit: 255
    t.string   "secret",               limit: 255
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.string   "hired_workflow_state", limit: 255, default: "Offer Accepted", null: false
    t.boolean  "found_namely_field",               default: false,            null: false
    t.integer  "attribute_mapper_id"
    t.integer  "installation_id",                                             null: false
  end

  add_index "jobvite_connections", ["attribute_mapper_id"], name: "index_jobvite_connections_on_attribute_mapper_id", using: :btree
  add_index "jobvite_connections", ["installation_id"], name: "index_jobvite_connections_on_installation_id", using: :btree

  create_table "net_suite_connections", force: :cascade do |t|
    t.string   "instance_id",         limit: 255
    t.string   "authorization",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "found_namely_field",              default: false, null: false
    t.string   "subsidiary_id",       limit: 255
    t.integer  "attribute_mapper_id"
    t.integer  "installation_id",                                 null: false
    t.boolean  "subsidiary_required"
  end

  add_index "net_suite_connections", ["attribute_mapper_id"], name: "index_net_suite_connections_on_attribute_mapper_id", using: :btree
  add_index "net_suite_connections", ["installation_id"], name: "index_net_suite_connections_on_installation_id", using: :btree

  create_table "profile_events", force: :cascade do |t|
    t.integer  "sync_summary_id", null: false
    t.string   "profile_name",    null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "error"
    t.string   "profile_id",      null: false
  end

  add_index "profile_events", ["error"], name: "index_profile_events_on_error", where: "(error IS NULL)", using: :btree
  add_index "profile_events", ["sync_summary_id"], name: "index_profile_events_on_sync_summary_id", using: :btree

  create_table "sync_summaries", force: :cascade do |t|
    t.integer  "connection_id",       null: false
    t.string   "connection_type",     null: false
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "authorization_error"
  end

  add_index "sync_summaries", ["connection_type", "connection_id"], name: "index_sync_summaries_on_connection_type_and_connection_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
    t.string   "namely_user_id",      limit: 255,                                 null: false
    t.string   "access_token",        limit: 255,                                 null: false
    t.string   "refresh_token",       limit: 255,                                 null: false
    t.string   "subdomain",           limit: 255,                                 null: false
    t.string   "first_name",          limit: 255
    t.string   "last_name",           limit: 255
    t.datetime "access_token_expiry",             default: '1970-01-01 00:00:00', null: false
    t.string   "email",               limit: 255
    t.integer  "installation_id",                                                 null: false
  end

  add_index "users", ["installation_id"], name: "index_users_on_installation_id", using: :btree

end
