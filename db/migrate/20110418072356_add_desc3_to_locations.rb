class AddDesc3ToLocations < ActiveRecord::Migration
  def self.up
    add_column :locations, :desc3, :text
  end

  def self.down
    remove_column :locations, :desc3
  end
end
