class AddCheckIdToLocations < ActiveRecord::Migration
  def self.up
    add_column :locations, :check_id, :integer
  end

  def self.down
    remove_column :locations, :check_id
  end
end
