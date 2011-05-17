class AddAoAdjToInventories < ActiveRecord::Migration
  def self.up
    add_column :inventories, :ao_adj, :integer
  end

  def self.down
    remove_column :inventories, :ao_adj
  end
end
