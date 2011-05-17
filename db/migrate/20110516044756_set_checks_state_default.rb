class SetChecksStateDefault < ActiveRecord::Migration
  def self.up
    change_column_default :checks, :state, 'init'
  end

  def self.down
    change_column_default :checks, :state, nil
  end
end
