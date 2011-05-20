class AddAlAccountToChecks < ActiveRecord::Migration
  def self.up
    add_column :checks, :al_account, :text
  end

  def self.down
    remove_column :checks, :al_account
  end
end
