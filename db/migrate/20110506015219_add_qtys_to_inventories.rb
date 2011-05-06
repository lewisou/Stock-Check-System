class AddQtysToInventories < ActiveRecord::Migration
  def self.up
    add_column :inventories, :inputed_qty, :integer
    add_column :inventories, :counted_qty, :integer
    add_column :inventories, :result_qty, :integer
  end

  def self.down
    remove_column :inventories, :result_qty
    remove_column :inventories, :counted_qty
    remove_column :inventories, :inputed_qty
  end
end
