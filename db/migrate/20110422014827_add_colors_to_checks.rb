class AddColorsToChecks < ActiveRecord::Migration
  def self.up
    add_column :checks, :color_1, :string
    add_column :checks, :color_2, :string
    add_column :checks, :color_3, :string
  end

  def self.down
    remove_column :checks, :color_3
    remove_column :checks, :color_2
    remove_column :checks, :color_1
  end
end
