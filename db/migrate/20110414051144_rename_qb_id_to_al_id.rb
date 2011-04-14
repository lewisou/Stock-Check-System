class RenameQbIdToAlId < ActiveRecord::Migration
  def self.up
    rename_column :items, :qb_id, :al_id
    add_column :items, :max_quantity, :integer
  end

  def self.down
    rename_column :items, :al_id, :qb_id
    add_column :items, :max_quantity
  end
end
