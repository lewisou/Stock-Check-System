class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :admins, :username
    add_index :inventories, :check_id
    add_index :items, :code
    add_index :locations, :code
    add_index :quantities, :inventory_id
    add_index :quantities, :time
    add_index :roles, :code
    add_index :tags, :state
    add_index :checks, :state
  end

  def self.down
    remove_index :admins, :username
    remove_index :inventories, :check_id
    remove_index :items, :code
    remove_index :locations, :code
    remove_index :quantities, :inventory_id
    remove_index :quantities, :time
    remove_index :roles, :code
    remove_index :tags, :state
    remove_index :checks, :state
  end
end
