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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120419210445) do

  create_table "albums", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "user_id"
    t.integer  "photo_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "auto_hide_from_users", :force => true do |t|
    t.integer  "user_id"
    t.integer  "hide_from_user_id"
    t.integer  "cover_type"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "auto_hide_when_with_users", :force => true do |t|
    t.integer  "auto_hide_from_user_id"
    t.integer  "user_id"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  create_table "face_hide_from_users", :force => true do |t|
    t.integer  "face_id"
    t.integer  "hide_from_user_id"
    t.integer  "cover_type"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "face_hide_when_with_users", :force => true do |t|
    t.integer  "face_hide_from_user_id"
    t.integer  "user_id"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  create_table "faces", :force => true do |t|
    t.integer  "photo_id"
    t.integer  "user_id"
    t.integer  "width"
    t.integer  "height"
    t.integer  "x"
    t.integer  "y"
    t.integer  "cover_type"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "forbidden_viewers", :force => true do |t|
    t.integer  "user_id"
    t.integer  "forbidden_viewer_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "global_auto_hide_froms", :force => true do |t|
    t.integer  "user_id"
    t.integer  "with_user_id"
    t.integer  "from_user_id"
    t.integer  "cover_type"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "pending_recognitions", :force => true do |t|
    t.integer  "face_id"
    t.integer  "user_id"
    t.decimal  "error_margin", :precision => 8, :scale => 3
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "photos", :force => true do |t|
    t.string   "ref"
    t.string   "name"
    t.string   "description"
    t.integer  "user_id"
    t.integer  "album_id"
    t.integer  "detection_width"
    t.integer  "detection_height"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "user_connections", :force => true do |t|
    t.integer  "user_id"
    t.integer  "connected_to_user_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "fname"
    t.string   "lname"
    t.string   "uname"
    t.string   "email"
    t.date     "dob"
    t.string   "hashed_password"
    t.string   "salt_password"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "auto_hide_from",  :default => 1
    t.integer  "auto_cover_type"
  end

end
