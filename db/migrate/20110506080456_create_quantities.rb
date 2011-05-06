class CreateQuantities < ActiveRecord::Migration
  def self.up
    create_table :quantities do |t|
      t.integer :time
      t.integer :value

      t.timestamps
    end
  end

  def self.down
    drop_table :quantities
  end
end
