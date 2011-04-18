class DropCountersLocations < ActiveRecord::Migration
  def self.up
    drop_table :counters_locations
  end

  def self.down
    create_table :counters_locations, :id => false do |t|
      t.references :counter
      t.references :location

    end

    add_index :counters_locations, :counter_id
    add_index :counters_locations, :location_id

  end
end
