class AddAuditToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :audit, :integer
  end

  def self.down
    remove_column :tags, :audit
  end
end
