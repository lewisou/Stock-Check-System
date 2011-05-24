class AddCheckIdToActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :check_id, :integer
  end

  def self.down
    remove_column :activities, :check_id
  end
end
