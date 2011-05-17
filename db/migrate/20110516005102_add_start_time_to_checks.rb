class AddStartTimeToChecks < ActiveRecord::Migration
  def self.up
    add_column :checks, :start_time, :datetime
  end

  def self.down
    remove_column :checks, :start_time
  end
end
