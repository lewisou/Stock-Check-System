class RenameColumnPartIdToItemIdInTags < ActiveRecord::Migration
  def self.up
    rename_column :tags, :part_id, :item_id
  end

  def self.down
    rename_column :tags, :item_id, :part_id
  end
end
