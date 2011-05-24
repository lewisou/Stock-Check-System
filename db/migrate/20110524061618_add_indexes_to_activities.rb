class AddIndexesToActivities < ActiveRecord::Migration
  def self.up
    add_index :activities, :admin_id
  end

  def self.down
    remove_index :activities, :admin_id
  end
end
