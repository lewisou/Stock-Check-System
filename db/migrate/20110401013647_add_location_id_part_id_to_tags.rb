class AddLocationIdPartIdToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :location_id, :integer
    add_column :tags, :part_id, :integer
  end

  def self.down
    remove_column :tags, :location_id
    remove_column :tags, :part_id
  end
end
