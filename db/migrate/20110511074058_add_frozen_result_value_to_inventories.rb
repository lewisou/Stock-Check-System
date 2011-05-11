class AddFrozenResultValueToInventories < ActiveRecord::Migration
  def self.up
    add_column :inventories, :result_value, :float
    add_column :inventories, :frozen_value, :float
  end

  def self.down
    remove_column :inventories, :frozen_value
    remove_column :inventories, :result_value
  end
end
