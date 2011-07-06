class AddColumnsToChecks < ActiveRecord::Migration
  def self.up
    add_column :checks, :import_item_groups_xls_id, :integer
    add_column :checks, :import_items_xls_id, :integer
    add_column :checks, :import_locations_xls_id, :integer
    add_column :checks, :import_inventories_xls_id, :integer
  end

  def self.down
    remove_column :checks, :import_inventories_xls_id
    remove_column :checks, :import_locations_xls_id
    remove_column :checks, :import_items_xls_id
    remove_column :checks, :import_item_groups_xls_id
  end
end
