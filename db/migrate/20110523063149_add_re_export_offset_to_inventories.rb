class AddReExportOffsetToInventories < ActiveRecord::Migration
  def self.up
    add_column :inventories, :re_export_offset, :integer
  end

  def self.down
    remove_column :inventories, :re_export_offset
  end
end
