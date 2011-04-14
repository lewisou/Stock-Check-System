class AddDescriptionToChecks < ActiveRecord::Migration
  def self.up
    add_column :checks, :description, :text
  end

  def self.down
    remove_column :checks, :description
  end
end
