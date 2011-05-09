class SetIsRemoteDefaultInLocations < ActiveRecord::Migration
  def self.up
    change_column_default(:locations, :is_remote, true)
  end

  def self.down
  end
end
