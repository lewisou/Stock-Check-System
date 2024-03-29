class DeviseCreateGods < ActiveRecord::Migration
  def self.up
    create_table(:gods) do |t|
      t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      t.trackable
      t.string :username
      # t.confirmable
      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      # t.token_authenticatable


      t.timestamps
    end

    add_index :gods, :username,             :unique => true
    add_index :gods, :email,                :unique => true
    add_index :gods, :reset_password_token, :unique => true
    # add_index :gods, :confirmation_token,   :unique => true
    # add_index :gods, :unlock_token,         :unique => true
  end

  def self.down
    drop_table :gods
  end
end
