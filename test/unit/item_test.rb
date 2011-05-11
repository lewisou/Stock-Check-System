require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  test "missing_cost" do
    scope = Location.create(:is_remote => true).inventories
    
    scope.create(:quantity => 1, :item => Item.create(:cost => 9))
    scope.create(:inputed_qty => 1, :item => Item.create(:cost => 9))
    
    
    scope.create(:quantity => 1, :item => i1 = Item.create(:cost => 0))
    scope.create(:quantity => 0, :item => Item.create(:cost => 0))
    scope.create(:quantity => 1, :item => i2 = Item.create)
    scope.create(:quantity => 0, :item => Item.create)

    scope.create(:inputed_qty => 1, :item => i3 = Item.create(:cost => 0))
    scope.create(:inputed_qty => 0, :item => Item.create(:cost => 0))
    scope.create(:inputed_qty => 1, :item => i4 = Item.create)
    scope.create(:inputed_qty => 0, :item => Item.create)


    assert Item.missing_cost.count == 4
    assert Item.missing_cost.all.include?(i1)
    assert Item.missing_cost.all.include?(i2)
    assert Item.missing_cost.all.include?(i3)
    assert Item.missing_cost.all.include?(i4)

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
    
    i.inventories.create(:location => Location.create(:is_remote => false)).tags.create(:count_1 => 2, :count_2 => 2)
    i.inventories.create(:location => Location.create(:is_remote => false)).tags.create(:count_1 => 2, :count_2 => 2)
    
    assert i.reload.counted_total_qty == 4
  end
  
  test "adj_max_quantity" do
    i = Item.create(:max_quantity => 1)
    i.inventories.create(:location => Location.create(:is_remote => false)).tags.create(:count_1 => 2, :count_2 => 2)
    i.reload
    
    i2 = Item.create
    i2.inventories.create(:location => Location.create(:is_remote => false)).tags.create(:count_1 => 2, :count_2 => 2)
    i2.reload

    i3 = Item.create(:max_quantity => 100)
    i3.inventories.create(:location => Location.create(:is_remote => false)).tags.create(:count_1 => 2, :count_2 => 2)
    i3.reload
    
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
#  inittags      :text
#

