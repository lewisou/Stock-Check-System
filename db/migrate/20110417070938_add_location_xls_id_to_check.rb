class AddLocationXlsIdToCheck < ActiveRecord::Migration
  def self.up
    add_column :checks, :location_xls_id, :integer
  end

  def self.down
    remove_column :checks, :location_xls_id
  end
end
