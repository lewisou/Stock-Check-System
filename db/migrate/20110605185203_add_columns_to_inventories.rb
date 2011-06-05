class AddColumnsToInventories < ActiveRecord::Migration
  def self.up
    add_column :inventories, :counted_1_value_differ, :float
    add_column :inventories, :counted_2_value_differ, :float
    add_column :inventories, :result_value_differ, :float
    
    Check.last.inventories.each do |inv|
      inv.save
    end
  end

  def self.down
    remove_column :inventories, :counted_1_value_differ
    remove_column :inventories, :counted_2_value_differ
    remove_column :inventories, :result_value_differ
  end
end
