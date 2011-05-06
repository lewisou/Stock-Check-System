class AddInventoryIdToQuantities < ActiveRecord::Migration
  def self.up
    add_column :quantities, :inventory_id, :integer
  end

  def self.down
    remove_column :quantities, :inventory_id
  end
end
