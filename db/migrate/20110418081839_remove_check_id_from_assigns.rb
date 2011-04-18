class RemoveCheckIdFromAssigns < ActiveRecord::Migration
  def self.up
    remove_column :assigns, :check_id
  end

  def self.down
    add_column :assigns, :check_id, :integer
  end
end
