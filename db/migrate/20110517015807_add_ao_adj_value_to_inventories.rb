class AddAoAdjValueToInventories < ActiveRecord::Migration
  def self.up
    add_column :inventories, :ao_adj_value, :float
  end

  def self.down
    remove_column :inventories, :ao_adj_value
  end
end
