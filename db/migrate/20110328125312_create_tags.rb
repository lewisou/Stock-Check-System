class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.integer :count_1
      t.integer :count_2
      t.integer :count_3

      t.timestamps
    end
  end

  def self.down
    drop_table :tags
  end
end
