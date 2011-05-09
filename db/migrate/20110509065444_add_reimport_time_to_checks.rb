class AddReimportTimeToChecks < ActiveRecord::Migration
  def self.up
    add_column :checks, :import_time, :integer, :default => 1
  end

  def self.down
    remove_column :checks, :import_time
  end
end
