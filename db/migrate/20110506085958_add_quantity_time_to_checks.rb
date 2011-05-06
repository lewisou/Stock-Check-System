class AddQuantityTimeToChecks < ActiveRecord::Migration
  def self.up
    add_column :checks, :quantity_time, :integer
  end

  def self.down
    remove_column :checks, :quantity_time
  end
end
