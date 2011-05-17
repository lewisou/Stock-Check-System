class AddCreditsToChecks < ActiveRecord::Migration
  def self.up
    add_column :checks, :credit_v, :float
    add_column :checks, :credit_q, :float
  end

  def self.down
    remove_column :checks, :credit_q
    remove_column :checks, :credit_v
  end
end
