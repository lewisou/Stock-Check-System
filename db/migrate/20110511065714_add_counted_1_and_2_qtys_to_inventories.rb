class AddCounted1And2QtysToInventories < ActiveRecord::Migration
  def self.up
    add_column :inventories, :counted_1_qty, :integer
    add_column :inventories, :counted_2_qty, :integer
  end

  def self.down
    remove_column :inventories, :counted_2_qty
    remove_column :inventories, :counted_1_qty
  end
end
