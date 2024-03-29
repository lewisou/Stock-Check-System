require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  test "mark_flag" do
    l = Location.create(:data_changed => false)
    assert l.data_changed == false
    
    l.save
    assert l.data_changed == true
  end
  
  test "refresh_assigns" do
    c = new_blank_check
    l = c.locations.create

    2.times {l.assigns.create}
    assert l.assigns.count == 2
    
    rs = []
    3.times {rs << Assign.create}
    
    l.new_assigns = rs
    l.curr_check = c
    l.save
    
    assert l.assigns.count == 3
    assert Location.find(l.id).assigns == rs.collect {|e| Assign.find(e.id)}
  end
  
  test "description" do
    assert Location.create(:desc1 => "1", :desc2 => "2", :desc3 => "3").description == "1 2 3"
  end
  
  test "available_counters" do
    c1 = Counter.create
    c2 = Counter.create
    c3 = Counter.create
    
    
    l = Location.create
    l.assigns.create(:count => 1, :counter => c1)
    l.assigns.create(:count => 2, :counter => c2)
    
    assert l.available_counters(1).count == 1
    assert l.available_counters(2).count == 1
    
    assert l.available_counters(1).first == c3
    assert l.available_counters(2).first == c3
  end
  
  test "has_available_counters?" do
    c1 = Counter.create
    c2 = Counter.create
    c3 = Counter.create
    
    l = Location.create
    l.assigns.create(:count => 1, :counter => c1)
    l.assigns.create(:count => 2, :counter => c2)
    
    assert l.has_available_counters?
    
    l.assigns.create(:count => 2, :counter => c3)
    
    assert !l.has_available_counters?
  end
  
  test "counter_names" do
    l = Location.create

    ["A", "BC", "DEF"].each do |n|
      l.assigns.create(:count => 1, :counter => Counter.create(:name => n))
    end

    assert l.counter_names(1) == "A, BC, DEF"
  end
  
  test "ensure_is_remote_has_a_value" do
    l = Location.create
    
    assert l.is_remote
  end
  
  test "tagable scope" do
    l = Location.create(:is_remote => false)
    Location.create(:is_remote => true)
    
    assert Location.tagable == [l]
  end
  
  test "not tagable scope" do
    Location.create(:is_remote => false)
    l = Location.create(:is_remote => true)
    
    assert Location.not_tagable == [l]
  end
  
  test "launch_inv_save" do
    loc = Location.create(:is_remote => false)
    inv = loc.inventories.create
    
    inv.tags.create(:count_1 => 3, :count_2 => 3)
    inv.tags.create(:count_1 => 4, :count_2 => 4)
    
    loc2 = Location.create(:is_remote => true)
    inv2 = loc2.inventories.create(:inputed_qty => 5)

    assert inv.reload.result_qty == 7
    assert inv2.reload.result_qty == 5

    loc.update_attributes(:is_remote => true)
    loc2.update_attributes(:is_remote => false)

    assert inv.reload.result_qty == 0
    assert inv2.reload.result_qty == 0
  end

  test "remote_newable" do
    check = new_blank_check
    item_groups = check.item_groups.create
    remote_location_1 = check.locations.create(:is_remote => true)
    remote_location_2 = check.locations.create(:is_remote => true)
    onsite_location_1 = check.locations.create(:is_remote => false)

    item1 = item_groups.items.create
    item2 = item_groups.items.create

    remote_location_1.inventories.create(:item => item1)
    remote_location_1.inventories.create(:item => item2)
    remote_location_1.inventories.create

    remote_location_2.inventories.create(:item => item2)
    remote_location_2.inventories.create

    onsite_location_1.inventories.create(:item => item1)
    onsite_location_1.inventories.create(:item => item2)
    onsite_location_1.inventories.create

    assert check.locations.remote_not_newable(item1).include?(remote_location_1)
    assert check.locations.remote_not_newable(item1).count == 1

    assert check.locations.remote_not_newable(item2).include?(remote_location_1)
    assert check.locations.remote_not_newable(item2).include?(remote_location_2)
    assert check.locations.remote_not_newable(item2).count == 2


    # lo0.inventories.create(:item => i)
    # 
    # c.locations.create(:is_remote => true)
    # 
    # 
    # 
    # .inventories.create(:item => i)
    # 
    # (lo1 = c.locations.create(:is_remote => true)).inventories.create(:item => i2)
    # (lo2 = c.locations.create(:is_remote => true)).inventories.create
    # lo3 = c.locations.create(:is_remote => true)
    # 
    # # onsite inventory
    # c.locations.create(:is_remote => false).inventories.create(:item => i)
    # 
    # assert !c.locations.remote_newable(i).include?(lo0)
    # assert c.locations.remote_newable(i).include?(lo1)
    # assert c.locations.remote_newable(i).include?(lo2)
    # assert c.locations.remote_newable(i).include?(lo3)
    # 
    # assert c.locations.remote_newable(i).count == 3
    # assert c.locations.count == 6
  end
end


# == Schema Information
#
# Table name: locations
#
#  id           :integer         not null, primary key
#  code         :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  is_available :boolean
#  is_active    :boolean
#  check_id     :integer
#  from_al      :boolean         default(FALSE)
#  data_changed :boolean         default(FALSE)
#  desc1        :text
#  desc2        :text
#  desc3        :text
#  is_remote    :boolean         default(TRUE)
#

