class AddInstructionIdToChecks < ActiveRecord::Migration
  def self.up
    add_column :checks, :instruction_id, :integer
  end

  def self.down
    remove_column :checks, :instruction_id
  end
end
