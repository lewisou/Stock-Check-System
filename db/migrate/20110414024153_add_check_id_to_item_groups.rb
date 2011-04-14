class AddCheckIdToItemGroups < ActiveRecord::Migration
  def self.up
    add_column :item_groups, :check_id, :integer
  end

  def self.down
    remove_column :item_groups, :check_id
  end
end
