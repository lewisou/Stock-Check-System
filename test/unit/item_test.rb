require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  test "missing_cost" do
    Item.create(:cost => 9).inventories.create(:quantity => 1, :cached_counted => 1)
    i1 = Item.create(:cost => 0); i1.inventories.create(:quantity => 1, :cached_counted => 1)
    i2 = Item.create; i2.inventories.create(:quantity => 1)
    i3 = Item.create; i3.inventories.create(:cached_counted => 1)
    Item.create.inventories.create()
    Item.create

    assert Item.missing_cost.count == 3
    assert Item.missing_cost.all.include?(i1)
    assert Item.missing_cost.all.include?(i2)
    assert Item.missing_cost.all.include?(i3)

  end
  
  test "need_adjustment" do
    Item.create(:from_al => true, :data_changed => false)
    i1 = Item.create # from_al => false, datachanged => false as default
    i2 = Item.create(:from_al => false, :data_changed => false)
    i3 = Item.create(:from_al => true, :data_changed => true)
    
    assert Item.need_adjustment.count == 3
    assert Item.need_adjustment.all.include?(i1)
    assert Item.need_adjustment.all.include?(i2)
    assert Item.need_adjustment.all.include?(i3)

  end
  
  test "mark_flag" do
    i = Item.create
    i.data_changed = false
    i.save
    
    assert Item.find(i.id).data_changed == true
  end
  
  test "group_name" do
    assert ItemGroup.create(:name => "gn").items.create.group_name == 'gn'
    assert ItemGroup.create.items.create.group_name == nil
  end
  
  test "counted_total_qty" do
    i = Item.create
    
    i.inventories.create.tags.create(:count_1 => 2, :count_2 => 2)
    i.inventories.create.tags.create(:count_1 => 2, :count_2 => 2)
    
    assert i.counted_total_qty == 4
  end
  
  test "adj_max_quantity" do
    i = Item.create(:max_quantity => 1)
    i.inventories.create.tags.create(:count_1 => 2, :count_2 => 2)
    
    i2 = Item.create
    i2.inventories.create.tags.create(:count_1 => 2, :count_2 => 2)

    i3 = Item.create(:max_quantity => 100)
    i3.inventories.create.tags.create(:count_1 => 2, :count_2 => 2)
    
    
    assert i.adj_max_quantity == 2
    assert i2.adj_max_quantity == nil
    assert i3.adj_max_quantity == nil
  end
end
# == Schema Information
#
# Table name: items
#
#  id            :integer         not null, primary key
#  code          :string(255)
#  description   :text
#  cost          :float
#  created_at    :datetime
#  updated_at    :datetime
#  al_id         :integer
#  max_quantity  :integer
#  item_group_id :integer
#  from_al       :boolean         default(FALSE)
#  al_cost       :float
#  data_changed  :boolean         default(FALSE)
#  is_active     :boolean
#

