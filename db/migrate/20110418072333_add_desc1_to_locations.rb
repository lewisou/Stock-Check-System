class AddDesc1ToLocations < ActiveRecord::Migration
  def self.up
    add_column :locations, :desc1, :text
  end

  def self.down
    remove_column :locations, :desc1
  end
end
