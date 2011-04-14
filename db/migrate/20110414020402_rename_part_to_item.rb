class RenamePartToItem < ActiveRecord::Migration
  def self.up
    rename_table :parts, :items
  end

  def self.down
    rename_table :items, :parts
  end
end
