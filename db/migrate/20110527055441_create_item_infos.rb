class CreateItemInfos < ActiveRecord::Migration
  def self.up
    create_table :item_infos do |t|
      t.integer :res_qty
      t.integer :item_id

      t.timestamps
    end
  end

  def self.down
    drop_table :item_infos
  end
end
