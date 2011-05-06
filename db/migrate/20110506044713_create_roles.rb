class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :code

      t.timestamps
    end

    create_table :admins_roles, :id => false do |t|
      t.integer :admin_id
      t.integer :role_id
    end
    
    add_index :admins_roles, :admin_id
    add_index :admins_roles, :role_id
  end

  def self.down
    drop_table :roles
  end
end
