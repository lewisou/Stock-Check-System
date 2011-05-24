class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.integer :admin_id
      t.text :request
      t.text :response
      t.datetime :ended_at
      t.boolean :finish, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :activities
  end
end
