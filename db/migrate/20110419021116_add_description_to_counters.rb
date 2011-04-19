class AddDescriptionToCounters < ActiveRecord::Migration
  def self.up
    add_column :counters, :description, :text
  end

  def self.down
    remove_column :counters, :description
  end
end
