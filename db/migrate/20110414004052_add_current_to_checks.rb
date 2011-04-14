class AddCurrentToChecks < ActiveRecord::Migration
  def self.up
    add_column :checks, :current, :boolean, :default => false
  end

  def self.down
    remove_column :checks, :current
  end
end
