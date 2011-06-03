class AddPrintedTimeToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :printed_time, :integer, :default => 0

    Tag.update_all(:printed_time => 0)
  end

  def self.down
    remove_column :tags, :printed_time
  end
end
