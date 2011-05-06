class AddTimeToInventories < ActiveRecord::Migration
  def self.up
    add_column :inventories, :time, :integer
  end

  def self.down
    remove_column :inventories, :time
  end
end
