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

ActiveRecord::Schema.define(version: 20170310175750) do

  create_table "acronyms", force: :cascade do |t|
    t.string   "initialism"
    t.boolean  "bracketed"
    t.boolean  "bracketed_on_first_use"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "document_id"
    t.text     "context_before"
    t.text     "context_after"
  end

  add_index "acronyms", ["document_id"], name: "index_acronyms_on_document_id"

  create_table "definitions", force: :cascade do |t|
    t.integer  "dictionary_id"
    t.string   "initialism"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "meaning"
  end

  add_index "definitions", ["dictionary_id"], name: "index_definitions_on_dictionary_id"

  create_table "dictionaries", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "documents", force: :cascade do |t|
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "file"
    t.boolean  "allow_mixedcase", default: false
    t.boolean  "allow_plurals",   default: false
    t.boolean  "allow_hyphens",   default: false
    t.boolean  "allow_numbers",   default: false
    t.boolean  "allow_short"
  end

end
