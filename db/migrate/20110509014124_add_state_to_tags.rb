class AddStateToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :state, :string
  end

  def self.down
    remove_column :tags, :state
  end
end
