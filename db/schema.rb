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

ActiveRecord::Schema.define(:version => 20110523081257) do

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
    t.string   "username"
  end

  add_index "admins", ["email"], :name => "index_admins_on_email", :unique => true
  add_index "admins", ["reset_password_token"], :name => "index_admins_on_reset_password_token", :unique => true
  add_index "admins", ["username"], :name => "index_admins_on_username"

  create_table "admins_roles", :id => false, :force => true do |t|
    t.integer "admin_id"
    t.integer "role_id"
  end

  add_index "admins_roles", ["admin_id"], :name => "index_admins_roles_on_admin_id"
  add_index "admins_roles", ["role_id"], :name => "index_admins_roles_on_role_id"

  create_table "assigns", :force => true do |t|
    t.integer  "count"
    t.integer  "counter_id"
    t.integer  "location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "assigns", ["counter_id"], :name => "index_assigns_on_counter_id"
  add_index "assigns", ["location_id"], :name => "index_assigns_on_location_id"

  create_table "attachments", :force => true do |t|
    t.string   "data_file_name"
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.datetime "data_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checks", :force => true do |t|
    t.string   "state",             :default => "init"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "current",           :default => false
    t.text     "description"
    t.integer  "admin_id"
    t.integer  "location_xls_id"
    t.integer  "inv_adj_xls_id"
    t.integer  "item_xls_id"
    t.string   "color_1"
    t.string   "color_2"
    t.string   "color_3"
    t.boolean  "generated",         :default => false
    t.integer  "import_time",       :default => 1
    t.integer  "instruction_id"
    t.date     "start_time"
    t.date     "end_time"
    t.float    "credit_v"
    t.float    "credit_q"
    t.text     "al_account"
    t.integer  "manual_adj_xls_id"
    t.boolean  "final_inv",         :default => false
  end

  add_index "checks", ["state"], :name => "index_checks_on_state"

  create_table "counters", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
  end

  create_table "gods", :force => true do |t|
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
    t.string   "username"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gods", ["email"], :name => "index_gods_on_email", :unique => true
  add_index "gods", ["reset_password_token"], :name => "index_gods_on_reset_password_token", :unique => true
  add_index "gods", ["username"], :name => "index_gods_on_username", :unique => true

  create_table "inventories", :force => true do |t|
    t.integer  "item_id"
    t.integer  "location_id"
    t.integer  "quantity",         :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "from_al",          :default => false
    t.integer  "inputed_qty"
    t.integer  "counted_qty"
    t.integer  "result_qty"
    t.integer  "check_id"
    t.boolean  "tag_inited",       :default => false
    t.integer  "counted_1_qty"
    t.integer  "counted_2_qty"
    t.float    "counted_1_value"
    t.float    "counted_2_value"
    t.float    "result_value"
    t.float    "frozen_value"
    t.integer  "ao_adj"
    t.float    "ao_adj_value"
    t.integer  "re_export_qty"
    t.integer  "re_export_offset"
  end

  add_index "inventories", ["check_id"], :name => "index_inventories_on_check_id"
  add_index "inventories", ["item_id"], :name => "index_inventories_on_item_id"
  add_index "inventories", ["location_id"], :name => "index_inventories_on_location_id"

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

  add_index "item_groups", ["check_id"], :name => "index_item_groups_on_check_id"

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
    t.boolean  "is_active"
    t.text     "inittags"
  end

  add_index "items", ["code"], :name => "index_items_on_code"
  add_index "items", ["item_group_id"], :name => "index_items_on_item_group_id"

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
    t.boolean  "is_remote",    :default => true
  end

  add_index "locations", ["check_id"], :name => "index_locations_on_check_id"
  add_index "locations", ["code"], :name => "index_locations_on_code"

  create_table "quantities", :force => true do |t|
    t.integer  "time"
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "inventory_id"
    t.boolean  "from_al"
  end

  add_index "quantities", ["inventory_id"], :name => "index_quantities_on_inventory_id"
  add_index "quantities", ["time"], :name => "index_quantities_on_time"

  create_table "roles", :force => true do |t|
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description"
  end

  add_index "roles", ["code"], :name => "index_roles_on_code"

  create_table "tags", :force => true do |t|
    t.integer  "count_1"
    t.integer  "count_2"
    t.integer  "count_3"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "inventory_id"
    t.string   "sloc"
    t.integer  "final_count"
    t.string   "state"
    t.integer  "adjustment"
    t.integer  "audit"
  end

  add_index "tags", ["inventory_id"], :name => "index_tags_on_inventory_id"
  add_index "tags", ["state"], :name => "index_tags_on_state"

end
