class AddTagInitedToInventories < ActiveRecord::Migration
  def self.up
    add_column :inventories, :tag_inited, :boolean, :default => false
  end

  def self.down
    remove_column :inventories, :tag_inited
  end
end
