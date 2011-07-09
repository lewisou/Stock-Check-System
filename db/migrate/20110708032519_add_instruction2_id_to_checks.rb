class AddInstruction2IdToChecks < ActiveRecord::Migration
  def self.up
    add_column :checks, :instruction2_id, :integer
    add_column :checks, :instruction3_id, :integer
    add_column :checks, :instruction4_id, :integer
  end

  def self.down
    remove_column :checks, :instruction2_id
    remove_column :checks, :instruction3_id
    remove_column :checks, :instruction4_id
  end
end
