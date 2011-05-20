class AddImportTimeToInventories < ActiveRecord::Migration
  def self.up
    add_column :inventories, :import_time, :integer
  end

  def self.down
    remove_column :inventories, :import_time
  end
end
