class AddItemGroupIdToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :item_group_id, :integer
  end

  def self.down
    remove_column :items, :item_group_id
  end
end
