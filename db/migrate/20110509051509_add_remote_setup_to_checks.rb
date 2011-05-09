class AddRemoteSetupToChecks < ActiveRecord::Migration
  def self.up
    add_column :checks, :generated, :boolean, :default => false
  end

  def self.down
    remove_column :checks, :generated
  end
end
