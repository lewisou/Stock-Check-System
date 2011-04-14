class CreateItemGroups < ActiveRecord::Migration
  def self.up
    create_table :item_groups do |t|
      t.text :name
      t.string :item_type
      t.string :item_type_short
      t.boolean :is_purchased
      t.boolean :is_sold
      t.boolean :is_used
      t.boolean :is_active

      t.timestamps
    end
  end

  def self.down
    drop_table :item_groups
  end
end
