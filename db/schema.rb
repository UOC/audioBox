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

ActiveRecord::Schema.define(:version => 20120427084258) do

  create_table "coments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "user_file_id"
    t.text     "comentario"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "coments", ["user_file_id"], :name => "index_coments_on_user_file_id"
  add_index "coments", ["user_id"], :name => "index_coments_on_user_id"

  create_table "folders", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "orden"
    t.integer  "user_id"
    t.integer  "parent_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "tipo"
    t.string   "modificado"
  end

  add_index "folders", ["parent_id"], :name => "index_folders_on_parent_id"
  add_index "folders", ["user_id"], :name => "index_folders_on_user_id"

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "groups_users", :id => false, :force => true do |t|
    t.integer "group_id"
    t.integer "user_id"
  end

  create_table "libraries", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.string   "autor"
    t.string   "site"
    t.string   "assignatura"
    t.string   "periodo"
    t.string   "security"
    t.integer  "user_id"
    t.integer  "folder_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.boolean  "is_preferido"
  end

  add_index "libraries", ["name", "title"], :name => "index_libraries_on_name_and_title"
  add_index "libraries", ["user_id"], :name => "index_libraries_on_user_id"

  create_table "permissions", :force => true do |t|
    t.integer "folder_id"
    t.integer "group_id"
    t.boolean "can_create"
    t.boolean "can_read"
    t.boolean "can_update"
    t.boolean "can_delete"
  end

  create_table "shared_folders", :force => true do |t|
    t.integer  "user_id"
    t.string   "shared_email"
    t.integer  "shared_user_id"
    t.integer  "folder_id"
    t.integer  "library_id"
    t.string   "message"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "shared_folders", ["folder_id"], :name => "index_shared_folders_on_folder_id"
  add_index "shared_folders", ["shared_user_id"], :name => "index_shared_folders_on_shared_user_id"
  add_index "shared_folders", ["user_id"], :name => "index_shared_folders_on_user_id"

  create_table "taggings", :force => true do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string  "taggable_type"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type"], :name => "index_taggings_on_tag_id_and_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  add_index "tags", ["name"], :name => "index_tags_on_name"

  create_table "user_files", :force => true do |t|
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.string   "tipo"
    t.integer  "orden"
    t.string   "description"
    t.string   "attachment"
    t.integer  "folder_id"
    t.integer  "user_id"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "user_files", ["folder_id"], :name => "index_user_files_on_folder_id"
  add_index "user_files", ["user_id"], :name => "index_user_files_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "hashed_password"
    t.string   "password_salt"
    t.boolean  "is_admin"
    t.boolean  "is_clasic_upload"
    t.boolean  "is_clasic_dialog"
    t.boolean  "is_alto_contraste"
    t.string   "access_key"
    t.string   "remember_token"
    t.string   "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.string   "locale"
    t.integer  "campususer"
    t.string   "campuslogin"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "users", ["campususer"], :name => "index_users_on_campususer", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
