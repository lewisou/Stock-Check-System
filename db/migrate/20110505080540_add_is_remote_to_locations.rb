class AddIsRemoteToLocations < ActiveRecord::Migration
  def self.up
    add_column :locations, :is_remote, :boolean
  end

  def self.down
    remove_column :locations, :is_remote
  end
end
