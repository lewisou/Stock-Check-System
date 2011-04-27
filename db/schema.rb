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

ActiveRecord::Schema.define(:version => 20110426030551) do

  create_table "admins", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "password_salt",                       :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admins", ["email"], :name => "index_admins_on_email", :unique => true
  add_index "admins", ["reset_password_token"], :name => "index_admins_on_reset_password_token", :unique => true

  create_table "assigns", :force => true do |t|
    t.integer  "count"
    t.integer  "counter_id"
    t.integer  "location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "attachments", :force => true do |t|
    t.string   "data_file_name"
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.datetime "data_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checks", :force => true do |t|
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "current",         :default => false
    t.text     "description"
    t.integer  "admin_id"
    t.integer  "location_xls_id"
    t.integer  "inv_adj_xls_id"
    t.integer  "item_xls_id"
    t.string   "color_1"
    t.string   "color_2"
    t.string   "color_3"
  end

  create_table "counters", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
  end

  create_table "inventories", :force => true do |t|
    t.integer  "item_id"
    t.integer  "location_id"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "from_al",        :default => false
    t.integer  "cached_counted"
  end

  create_table "item_groups", :force => true do |t|
    t.text     "name"
    t.string   "item_type"
    t.string   "item_type_short"
    t.boolean  "is_purchased"
    t.boolean  "is_sold"
    t.boolean  "is_used"
    t.boolean  "is_active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "check_id"
  end

  create_table "items", :force => true do |t|
    t.string   "code"
    t.text     "description"
    t.float    "cost"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "al_id"
    t.integer  "max_quantity"
    t.integer  "item_group_id"
    t.boolean  "from_al",       :default => false
    t.float    "al_cost"
    t.boolean  "data_changed",  :default => false
  end

  create_table "locations", :force => true do |t|
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_available"
    t.boolean  "is_active"
    t.integer  "check_id"
    t.boolean  "from_al",      :default => false
    t.boolean  "data_changed", :default => false
    t.text     "desc1"
    t.text     "desc2"
    t.text     "desc3"
  end

  create_table "tags", :force => true do |t|
    t.integer  "count_1"
    t.integer  "count_2"
    t.integer  "count_3"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "inventory_id"
    t.string   "sloc"
  end

end
