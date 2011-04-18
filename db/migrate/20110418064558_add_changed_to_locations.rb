class AddChangedToLocations < ActiveRecord::Migration
  def self.up
    add_column :locations, :data_changed, :boolean, :default => false
  end

  def self.down
    remove_column :locations, :data_changed
  end
end
