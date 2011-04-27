class AddSlocToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :sloc, :string
  end

  def self.down
    remove_column :tags, :sloc
  end
end
