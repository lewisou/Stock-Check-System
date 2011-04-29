class AddInittagsToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :inittags, :text
  end

  def self.down
    remove_column :items, :inittags
  end
end
