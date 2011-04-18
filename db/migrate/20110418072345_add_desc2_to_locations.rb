class AddDesc2ToLocations < ActiveRecord::Migration
  def self.up
    add_column :locations, :desc2, :text
  end

  def self.down
    remove_column :locations, :desc2
  end
end
