class AddAoAdjustAccToChecks < ActiveRecord::Migration
  def self.up
    add_column :checks, :ao_adjust_acc, :text, :default => 'INVENTORY:INVENTORY ADJUSTMENTS'
  end

  def self.down
    remove_column :checks, :ao_adjust_acc
  end
end
