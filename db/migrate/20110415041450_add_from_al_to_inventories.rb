class AddFromAlToInventories < ActiveRecord::Migration
  def self.up
    add_column :inventories, :from_al, :boolean, :default => false
  end

  def self.down
    remove_column :inventories, :from_al
  end
end
