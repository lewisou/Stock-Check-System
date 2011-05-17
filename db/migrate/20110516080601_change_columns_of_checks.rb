class ChangeColumnsOfChecks < ActiveRecord::Migration
  def self.up
    change_column(:checks, :start_time, :date)
    change_column(:checks, :end_time, :date)
  end

  def self.down
    change_column(:checks, :start_time, :datetime)
    change_column(:checks, :end_time, :datetime)
  end
end
