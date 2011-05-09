class RemoveTimeFromInventories < ActiveRecord::Migration
  def self.up
    remove_column :inventories, :time
  end

  def self.down
    add_column :inventories, :time, :integer
  end
end
