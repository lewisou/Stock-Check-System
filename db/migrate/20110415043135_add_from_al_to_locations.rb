class AddFromAlToLocations < ActiveRecord::Migration
  def self.up
    add_column :locations, :from_al, :boolean, :default => false
  end

  def self.down
    remove_column :locations, :from_al
  end
end
