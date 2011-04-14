class RemoveItemIdAndLocationIdFromTags < ActiveRecord::Migration
  def self.up
    remove_column :tags, :location_id
    remove_column :tags, :item_id
    add_column :tags, :inventory_id, :integer
  end

  def self.down
    add_column :tags, :location_id, :integer
    add_column :tags, :item_id, :integer
    remove_column :tags, :inventory_id
  end
end
