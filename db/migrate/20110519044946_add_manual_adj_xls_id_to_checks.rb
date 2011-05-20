class AddManualAdjXlsIdToChecks < ActiveRecord::Migration
  def self.up
    add_column :checks, :manual_adj_xls_id, :integer
  end

  def self.down
    remove_column :checks, :manual_adj_xls_id
  end
end
