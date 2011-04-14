class AddIsAvailableIsActiveToLocations < ActiveRecord::Migration
  def self.up
    add_column :locations, :is_available, :boolean
    add_column :locations, :is_active, :boolean
  end

  def self.down
    remove_column :locations, :is_active
    remove_column :locations, :is_available
  end
end
