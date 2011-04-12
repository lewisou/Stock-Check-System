class AddQbIdToParts < ActiveRecord::Migration
  def self.up
    add_column :parts, :qb_id, :integer
  end

  def self.down
    remove_column :parts, :qb_id
  end
end
