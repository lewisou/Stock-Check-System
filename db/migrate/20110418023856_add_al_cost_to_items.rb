class AddAlCostToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :al_cost, :float
  end

  def self.down
    remove_column :items, :al_cost
  end
end
