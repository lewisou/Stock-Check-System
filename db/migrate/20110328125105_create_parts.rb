class CreateParts < ActiveRecord::Migration
  def self.up
    create_table :parts do |t|
      t.string :code
      t.text :description
      t.float :cost

      t.timestamps
    end
  end

  def self.down
    drop_table :parts
  end
end
