class AddRemoteSumToItems < ActiveRecord::Migration
  def self.up
    add_column :item_infos, :sum_remote_frozen_qty, :integer
    add_column :item_infos, :sum_remote_result_qty, :integer
    add_column :item_infos, :sum_remote_frozen_value, :float
    add_column :item_infos, :sum_remote_result_value, :float
  end

  def self.down
    remove_column :item_infos, :sum_remote_result_value
    remove_column :item_infos, :sum_remote_frozen_value
    remove_column :item_infos, :sum_remote_result_qty
    remove_column :item_infos, :sum_remote_frozen_qty
  end
end
