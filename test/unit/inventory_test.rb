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
    Inventory.create(:quantity => 1, :cached_counted => 1)
    i = Inventory.create(:quantity => 1, :cached_counted => 2)
    Inventory.create(:quantity => 1, :cached_counted => nil)
    Inventory.create(:quantity => nil, :cached_counted => nil)

    assert Inventory.need_adjustment.count == 1
    assert Inventory.need_adjustment.first == i
  end

  test "cache_counted" do
    c = new_blank_check
    l = c.locations.create

    i1 = l.inventories.create
    i1.tags.create(:count_1 => 2, :count_2 => 2)
    i1.tags.create(:count_1 => 2, :count_2 => 2)

    i2 = l.inventories.create
    i2.tags.create(:count_1 => 2, :count_2 => 2)

    i3 = l.inventories.create

    Inventory.cache_counted c
    assert Inventory.find(i1).cached_counted == 4
    assert Inventory.find(i2).cached_counted == 2
    assert Inventory.find(i3).cached_counted == 0

  end
  
  test "create_default_tag!" do
    i = Inventory.create
    i2 = Inventory.create
    i2.tags.create
    
    i.create_default_tag!
    i2.create_default_tag!
    
    assert i.tags.count == 1
    assert i2.tags.count == 1
  end
  
  test "counted" do
    i = Inventory.create
    i.tags.create(:count_1 => 1, :count_2 => 1)
    i.tags.create(:count_1 => 2, :count_2 => 2)
    
    assert i.counted == 3
  end
  
  test "frozen_value" do
    i = Item.create(:al_cost => 10)
    inv = i.inventories.create(:quantity => 9)
    
    assert inv.frozen_value == 90
  end

  test "counted_value" do
    i = Item.create(:cost => 10)
    inv = i.inventories.create
    inv.tags.create(:count_1 => 2, :count_2 => 2)
    inv.tags.create(:count_1 => 1, :count_2 => 1)
    
    assert inv.counted_value == 30
  end

  test "item_full_name" do
    assert Inventory.create.item_full_name == ""
    assert Inventory.create(:item => Item.create(:code => "bla")).item_full_name == "bla"
  end

  test "adj_count" do
    assert Inventory.create(:cached_counted => 50, :quantity => 30).adj_count == 20
  end
  
  test "adj_item_cost" do
    i = Item.create(:cost => 1)
    inv = i.inventories.create(:cached_counted => 50, :quantity => 30)
    inv2 = i.inventories.create(:cached_counted => 50, :quantity => 60)
    
    assert inv.adj_item_cost == 1
    assert inv2.adj_item_cost == nil
  end
end