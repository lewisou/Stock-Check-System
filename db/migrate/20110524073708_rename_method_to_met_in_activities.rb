class RenameMethodToMetInActivities < ActiveRecord::Migration
  def self.up
    rename_column :activities, :method, :met
  end

  def self.down
    rename_column :activities, :met, :method
  end
end
