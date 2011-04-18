class RemoveDescriptionFromLocations < ActiveRecord::Migration
  def self.up
    remove_column :locations, :description
  end

  def self.down
    add_column :locations, :description, :text
  end
end
