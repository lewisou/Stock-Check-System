class AddAdjustmentToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :adjustment, :integer
  end

  def self.down
    remove_column :tags, :adjustment
  end
end
