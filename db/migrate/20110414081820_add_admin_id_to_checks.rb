class AddAdminIdToChecks < ActiveRecord::Migration
  def self.up
    add_column :checks, :admin_id, :integer
  end

  def self.down
    remove_column :checks, :admin_id
  end
end
