class AddMethodToActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :method, :string
  end

  def self.down
    remove_column :activities, :method
  end
end
