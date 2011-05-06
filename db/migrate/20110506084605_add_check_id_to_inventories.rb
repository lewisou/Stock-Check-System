class AddCheckIdToInventories < ActiveRecord::Migration
  def self.up
    add_column :inventories, :check_id, :integer
  end

  def self.down
    remove_column :inventories, :check_id
  end
end
