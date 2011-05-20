class RemoveImportTimeFromInventories < ActiveRecord::Migration
  def self.up
    remove_column :inventories, :import_time
  end

  def self.down
    add_column :inventories, :import_time, :integer
  end
end
