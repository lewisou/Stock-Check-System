class AddFinalInvToChecks < ActiveRecord::Migration
  def self.up
    add_column :checks, :final_inv, :boolean, :default => false
  end

  def self.down
    remove_column :checks, :final_inv
  end
end
