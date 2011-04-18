class AddItemXlsIdToCheck < ActiveRecord::Migration
  def self.up
    add_column :checks, :item_xls_id, :integer
  end

  def self.down
    remove_column :checks, :item_xls_id
  end
end
