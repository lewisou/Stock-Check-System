class RenameAssginsToAssigns < ActiveRecord::Migration
  def self.up
    rename_table :assgins, :assigns
  end

  def self.down
    rename_table :assigns, :assgins
  end
end
