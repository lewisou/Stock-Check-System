require 'test_helper'

class InventoryTest < ActiveSupport::TestCase
  test "in_check scope" do
    c = Check.new; c.save(:validate => false)

    l = c.locations.create

    3.times {l.inventories.create}
    Inventory.create # one more inventory that does not associate to the check

    assert Inventory.in_check(c.id).count == 3
  end

  test "need_adjustment" do
    scope = Location.create(:is_remote => true).inventories

    scope.create(:quantity => 1, :inputed_qty => 1)
    
    i = scope.create(:quantity => 1, :inputed_qty => 2)
    scope.create(:quantity => 1, :inputed_qty => nil)
    scope.create(:quantity => nil, :inputed_qty => nil)

    assert Inventory.need_adjustment.count == 1
    assert Inventory.need_adjustment.first == i
  end

  test "create_default_tag!" do
    i = Inventory.create(:location => Location.create(:is_remote => false))
    i2 = Inventory.create(:location => Location.create(:is_remote => false))
    i2.tags.create
    
    i.create_default_tag!
    i2.create_default_tag!
    
    assert i.tags.count == 1
    assert i2.tags.count == 1
  end
  
  # test "counted" do
  #   i = Inventory.create(:location => Location.create)
  #   i.tags.create(:count_1 => 1, :count_2 => 1)
  #   i.tags.create(:count_1 => 2, :count_2 => 2)
  #   
  #   assert i.counted == 3
  # end
  
  test "frozen_value" do
    i = Item.create(:al_cost => 10)
    inv = i.inventories.create(:quantity => 9)
    
    assert inv.frozen_value == 90
  end

  test "counted_value" do
    i = Item.create(:cost => 10)
    inv = i.inventories.create(:location => Location.create(:is_remote => false))
    inv.tags.create(:count_1 => 2, :count_2 => 2)
    inv.tags.create(:count_1 => 1, :count_2 => 1)

    assert inv.reload.counted_value == 30
  end

  test "item_full_name" do
    assert Inventory.create.item_full_name == ""
    assert Inventory.create(:item => Item.create(:code => "bla")).item_full_name == "bla"
  end

  test "adj_count" do
    scope = Location.create(:is_remote => true).inventories
    
    assert scope.create(:quantity => 30, :inputed_qty => 50).adj_count == 20
  end
  
  test "adj_item_cost" do
    scope = Location.create(:is_remote => true).inventories
    i = Item.create(:cost => 2)

    inv = scope.create(:inputed_qty => 50, :quantity => 30, :item => i)
    inv2 = scope.create(:inputed_qty => 30, :quantity => 50, :item => i)
    
    assert inv.adj_item_cost == 2
    assert inv2.adj_item_cost == nil
  end
  
  test "counted_in" do
    i = Inventory.create(:location => Location.create)
    3.times {i.tags.create(:count_1 => 1)}
    2.times {i.tags.create(:count_2 => 1)}
    1.times {i.tags.create}
    
    assert i.counted_in_1 == 3
    assert i.counted_in_2 == 2
  end
  
  test "counted_value_in" do
    i = Inventory.create(:item => Item.create(:cost => 10), :location => Location.create)
    3.times {i.tags.create(:count_1 => 1)}
    2.times {i.tags.create(:count_2 => 1)}
    1.times {i.tags.create}
    
    assert i.counted_value_in_1 == 30
    assert i.counted_value_in_2 == 20
  end
  
  
  test "create init tags!" do
    l = Location.create(:code => 'CA', :is_remote => false)
    
    i1 = Item.create(:inittags => 'CA75H, CA74H')
    i2 = Item.create(:inittags => 'CZ75H, CZ74H')
    i3 = Item.create
    
    in1 = Inventory.create(:location => l, :item => i1)
    in2 = Inventory.create(:location => l, :item => i2)
    in3 = Inventory.create(:location => l, :item => i3)
    
    assert in1.create_init_tags! == 2
    assert in2.create_init_tags! == 0
    assert in3.create_init_tags! == 0
    assert in1.tags.count == 2
    assert in2.tags.count == 0
    assert in3.tags.count == 0
    assert Tag.count == 2

  end
  
  test "counted_qty" do
    onsite_inv = Location.create(:is_remote => false).inventories.create
    onsite_inv.tags.create(:count_1 => 2, :count_2 => 2)

    remote_inv = Location.create(:is_remote => true).inventories.create
    remote_inv.tags.create(:count_1 => 2, :count_2 => 2)
    
    assert onsite_inv.reload.counted_qty == 2
    assert remote_inv.reload.counted_qty.nil?
  end
  
  test "inputed_qty" do
    onsite_inv = Location.create(:is_remote => false).inventories.create(:inputed_qty => 2)
    remote_inv = Location.create(:is_remote => true).inventories.create(:inputed_qty => 2)
    
    assert onsite_inv.inputed_qty.nil?
    assert remote_inv.reload.inputed_qty == 2
  end
  
  test "result_qty" do
    onsite_inv = Location.create(:is_remote => false).inventories.create(:inputed_qty => 2)
    onsite_inv.tags.create(:count_1 => 3, :count_2 => 3)

    remote_inv = Location.create(:is_remote => true).inventories.create(:inputed_qty => 4)
    remote_inv.tags.create(:count_1 => 5, :count_2 => 5)

    assert onsite_inv.reload.result_qty == 3
    assert remote_inv.reload.result_qty == 4
    
    remote_inv.tags.first.destroy
    onsite_inv.tags.first.destroy
    
    assert onsite_inv.reload.result_qty == 0
    assert remote_inv.reload.result_qty == 4
  end
  
  test "quantity log" do
    c = new_blank_check

    inv = Inventory.create(:quantity => 3, :location => c.locations.create)

    c.update_attributes(:import_time => 2)
    inv.update_attributes(:quantity => 4)
    inv.attributes = {:quantity => 8}
    inv.save

    c.update_attributes(:import_time => 3)
    inv.update_attributes(:quantity => 4)
    inv.update_attributes(:quantity => nil)
    inv.update_attributes(:quantity => 2)

    assert inv.quantities.count == 3
    assert inv.quantities.where(:time => 1).count == 1
    assert inv.quantities.where(:time => 1).first.value == 3
    assert inv.quantities.where(:time => 2).count == 1
    assert inv.quantities.where(:time => 2).first.value == 4
    assert inv.quantities.where(:time => 3).count == 1
    assert inv.quantities.where(:time => 3).first.value == 4
  end

  test "adj_check" do
    c = new_blank_check
    inv = c.locations.create.inventories.create
    
    assert inv.check == c
  end
  
  test "create_init_tags! only once" do
    c = new_blank_check
    inv = c.locations.create(:code => 'CA', :is_remote => false).inventories.create(:item => Item.create(:inittags => 'CA75H, CA74H'))
    
    inv.create_init_tags!
    assert inv.tags.count == 2
    
    inv.create_init_tags!
    inv.create_init_tags!
    assert inv.tags.count == 2
  end
  
  test "Tags in remote locations will not be generated" do
    c = new_blank_check
    i1 = c.locations.create(:code => 'CA', :is_remote => false).inventories.create(:item => Item.create(:inittags => 'CA75H, CA74H'))
    i2 = c.locations.create(:code => 'RS', :is_remote => true).inventories.create(:item => Item.create(:inittags => 'CA75H, CA74H'))
    
    i1.create_default_tag!
    i1.create_init_tags!

    i2.create_default_tag!
    i2.create_init_tags!

    assert Tag.in_check(c.id).count == 3
  end

  test "init time to 0 when Inventory firstly created" do
    c = new_blank_check
    
    inv = Inventory.create(:quantity => 1, :location => c.locations.create)
    assert inv.quantities.count == 1
    assert inv.quantities.first.time == 1
  end
  
end





# == Schema Information
#
# Table name: inventories
#
#  id          :integer         not null, primary key
#  item_id     :integer
#  location_id :integer
#  quantity    :integer
#  created_at  :datetime
#  updated_at  :datetime
#  from_al     :boolean         default(FALSE)
#  inputed_qty :integer
#  counted_qty :integer
#  result_qty  :integer
#  check_id    :integer
#  tag_inited  :boolean         default(FALSE)
#

