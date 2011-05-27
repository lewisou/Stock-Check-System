class AddRemainingToItemInfos < ActiveRecord::Migration
  def self.up
    add_column :item_infos, :remaining, :integer
  end

  def self.down
    remove_column :item_infos, :remaining
  end
end
