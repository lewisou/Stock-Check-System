class CreateLocationInfos < ActiveRecord::Migration
  def self.up
    create_table :location_infos do |t|
      t.integer :sum_frozen_qty
      t.integer :sum_result_qty

      t.float :sum_frozen_value
      t.float :sum_result_value

      t.integer :location_id
      t.timestamps
    end
  end

  def self.down
    drop_table :location_infos
  end
end
