class DropBoxes < ActiveRecord::Migration
  def self.up
    drop_table :boxes
  end

  def self.down
    create_table :boxes do |t|
      t.timestamps
    end
  end
end
