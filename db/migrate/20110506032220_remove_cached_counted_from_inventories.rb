class RemoveCachedCountedFromInventories < ActiveRecord::Migration
  def self.up
    remove_column :inventories, :cached_counted
  end

  def self.down
    add_column :inventories, :cached_counted, :integer
  end
end
