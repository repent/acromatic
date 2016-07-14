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

ActiveRecord::Schema.define(version: 20160701184543) do

  create_table "acronyms", force: :cascade do |t|
    t.string   "initialism"
    t.text     "context"
    t.boolean  "bracketed"
    t.boolean  "bracketed_on_first_use"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "document_id"
  end

  add_index "acronyms", ["document_id"], name: "index_acronyms_on_document_id"

  create_table "documents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "file"
  end

end
