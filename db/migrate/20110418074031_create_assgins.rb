class CreateAssgins < ActiveRecord::Migration
  def self.up
    create_table :assgins do |t|
      t.integer :count
      t.integer :counter_id
      t.integer :location_id
      t.integer :check_id

      t.timestamps
    end
  end

  def self.down
    drop_table :assgins
  end
end
