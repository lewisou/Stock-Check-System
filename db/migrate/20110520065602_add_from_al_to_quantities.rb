class AddFromAlToQuantities < ActiveRecord::Migration
  def self.up
    add_column :quantities, :from_al, :boolean
  end

  def self.down
    remove_column :quantities, :from_al
  end
end
