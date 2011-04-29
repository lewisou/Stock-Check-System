class AddIsActiveToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :is_active, :boolean
  end

  def self.down
    remove_column :items, :is_active
  end
end
