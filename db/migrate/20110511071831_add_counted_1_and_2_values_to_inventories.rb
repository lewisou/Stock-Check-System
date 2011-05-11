class AddCounted1And2ValuesToInventories < ActiveRecord::Migration
  def self.up
    add_column :inventories, :counted_1_value, :float
    add_column :inventories, :counted_2_value, :float
  end

  def self.down
    remove_column :inventories, :counted_2_value
    remove_column :inventories, :counted_1_value
  end
end
