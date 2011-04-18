class AddCachedCountedToInventories < ActiveRecord::Migration
  def self.up
    add_column :inventories, :cached_counted, :integer
  end

  def self.down
    remove_column :inventories, :cached_counted
  end
end
