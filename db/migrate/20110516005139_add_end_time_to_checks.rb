class AddEndTimeToChecks < ActiveRecord::Migration
  def self.up
    add_column :checks, :end_time, :datetime
  end

  def self.down
    remove_column :checks, :end_time
  end
end
