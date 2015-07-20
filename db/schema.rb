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

ActiveRecord::Schema.define(version: 20150715184131) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attribute_mappers", force: true do |t|
    t.string   "mapping_direction", null: false
    t.integer  "user_id",           null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "attribute_mappers", ["user_id"], name: "index_attribute_mappers_on_user_id", using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "export_logs", force: true do |t|
    t.integer  "connection_id",   null: false
    t.string   "connection_type", null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "export_logs", ["connection_id", "connection_type"], name: "index_export_logs_on_connection_id_and_connection_type", using: :btree

  create_table "greenhouse_connections", force: true do |t|
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "secret_key"
    t.string   "name"
    t.boolean  "found_namely_field", default: false, null: false
    t.integer  "user_id",                            null: false
  end

  add_index "greenhouse_connections", ["user_id"], name: "index_greenhouse_connections_on_user_id", using: :btree

  create_table "icims_connections", force: true do |t|
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "username"
    t.integer  "user_id",                            null: false
    t.integer  "customer_id"
    t.boolean  "found_namely_field", default: false, null: false
    t.string   "key"
    t.string   "api_key"
  end

  add_index "icims_connections", ["user_id"], name: "index_icims_connections_on_user_id", using: :btree

  create_table "jobvite_connections", force: true do |t|
    t.string   "api_key"
    t.string   "secret"
    t.integer  "user_id",                                         null: false
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "hired_workflow_state", default: "Offer Accepted", null: false
    t.boolean  "found_namely_field",   default: false,            null: false
  end

  add_index "jobvite_connections", ["user_id"], name: "index_jobvite_connections_on_user_id", using: :btree

  create_table "net_suite_connections", force: true do |t|
    t.integer  "user_id"
    t.string   "instance_id"
    t.string   "authorization"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "found_namely_field", default: false, null: false
    t.string   "subsidiary_id"
  end

  add_index "net_suite_connections", ["user_id"], name: "index_net_suite_connections_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.string   "namely_user_id",                                      null: false
    t.string   "access_token",                                        null: false
    t.string   "refresh_token",                                       null: false
    t.string   "subdomain",                                           null: false
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "access_token_expiry", default: '1970-01-01 00:00:00', null: false
    t.string   "email"
  end

end
