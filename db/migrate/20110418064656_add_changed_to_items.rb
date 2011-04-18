class AddChangedToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :data_changed, :boolean, :default => false
  end

  def self.down
    remove_column :items, :data_changed
  end
end
