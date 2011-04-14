class CreateCountersLocations < ActiveRecord::Migration
  def self.up

    create_table :counters_locations, :id => false do |t|
      t.references :counter
      t.references :location

    end
    
    add_index :counters_locations, :counter_id
    add_index :counters_locations, :location_id
  end

  def self.down
    drop_table :counters_locations
  end
end
