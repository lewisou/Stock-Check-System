class AddHisMaxToInventories < ActiveRecord::Migration
  def self.up
    add_column :inventories, :his_max, :integer
  end

  def self.down
    remove_column :inventories, :his_max
  end
end
