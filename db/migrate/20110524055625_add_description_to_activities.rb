class AddDescriptionToActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :description, :text
  end

  def self.down
    remove_column :activities, :description
  end
end
