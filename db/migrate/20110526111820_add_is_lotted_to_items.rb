class AddIsLottedToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :is_lotted, :boolean, :default => false
  end

  def self.down
    remove_column :items, :is_lotted
  end
end
