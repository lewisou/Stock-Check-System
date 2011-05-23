class AddReExportQtyToInventories < ActiveRecord::Migration
  def self.up
    add_column :inventories, :re_export_qty, :integer
  end

  def self.down
    remove_column :inventories, :re_export_qty
  end
end
