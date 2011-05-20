class SetDefaultValueToInventoriesQuantity < ActiveRecord::Migration
  def self.up
    change_column_default :inventories, :quantity, 0
  end

  def self.down
    change_column_default :inventories, :quantity, nil
  end
end
