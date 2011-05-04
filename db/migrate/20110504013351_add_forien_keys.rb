class AddForienKeys < ActiveRecord::Migration
  def self.up
    add_index :tags, :inventory_id
    add_index :locations, :check_id
    add_index :items, :item_group_id
    add_index :item_groups, :check_id
    add_index :inventories, :item_id  
    add_index :inventories, :location_id
    add_index :assigns, :counter_id
    add_index :assigns, :location_id
  end

  def self.down
    remove_index :tags, :inventory_id
    remove_index :locations, :check_id
    remove_index :items, :item_group_id
    remove_index :item_groups, :check_id
    remove_index :inventories, :item_id  
    remove_index :inventories, :location_id
    remove_index :assigns, :counter_id
    remove_index :assigns, :location_id
  end
end
