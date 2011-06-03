class AddWaitForPrintToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :wait_for_print, :boolean, :default => true
    
    Tag.update_all(:wait_for_print => false)
  end

  def self.down
    remove_column :tags, :wait_for_print
  end
end
