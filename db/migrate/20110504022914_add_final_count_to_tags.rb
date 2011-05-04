class AddFinalCountToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :final_count, :integer
  end

  def self.down
    remove_column :tags, :final_count
  end
end
