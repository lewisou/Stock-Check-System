class AddFromAlToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :from_al, :boolean, :default => false
  end

  def self.down
    remove_column :items, :from_al
  end
end
