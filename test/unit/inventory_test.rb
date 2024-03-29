require 'test_helper'

class InventoryTest < ActiveSupport::TestCase
  test "in_check scope" do
    c = Check.new; c.save(:validate => false)

    l = c.locations.create

    3.times {l.inventories.create}
    Inventory.create # one more inventory that does not associate to the check

    assert Inventory.in_check(c.id).count == 3
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

  test "frozen_value" do
    i = Item.create(:cost => 10)
    inv = i.inventories.create(:quantity => 9, :location => Location.create(:is_remote => false))
    
    assert inv.reload.frozen_value == 90
  end

  test "counted_value" do
    i = Item.create(:cost => 10)
    inv = i.inventories.create(:location => Location.create(:is_remote => false))
    inv.tags.create(:count_1 => 2, :count_2 => 2)
    inv.tags.create(:count_1 => 1, :count_2 => 1)

    assert inv.reload.result_value == 30
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

  test "create init tags!" do
    "CA1-A, CA1-C, CA1-D, CA2-A,  CA3-A, CA3-B, FGFLOOR"
    
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
    
    
    al_i = Item.create(:inittags => "CA1-A, CA1-C, CA1-D, CA2-A,  CA3-A, CA3-B, FGFLOOR")
    inv_al_i = Inventory.create(:location => l, :item => al_i)
    assert inv_al_i.create_init_tags! == 6
    
    item = Item.create(:inittags => "CA74-E, CA74-F")
    inv = Inventory.create(:location => Location.create(:code => "CA", :is_remote => false), :item => item)
    inv.create_init_tags! == 2

    inv = Inventory.create(:location => Location.create(:code => "RS", :is_remote => false), :item => item)
    inv.create_init_tags! == 2
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
    
    assert onsite_inv.inputed_qty == 2
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
  
  test "log_qty_and_flag" do
    c = new_blank_check
    scope = c.locations.create.inventories
    
    inv1 = scope.create(:quantity => 3, :from_al => false)
    inv1.update_attributes(:quantity => 4, :from_al => true)

    c.switch_inv!(2)
    inv1.reload.update_attributes(:quantity => 5, :from_al => false)
    inv1.update_attributes(:quantity => nil, :from_al => false)

    inv1.reload.quantities.count == 2
    l1 = inv1.reload.quantities.where(:time => 1).first
    assert l1.value == 4
    assert l1.from_al == true

    l2 = inv1.reload.quantities.where(:time => 2).first
    assert l2.value == nil
    assert l2.from_al == false

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
  
  test "adj_qtys with tags deleted" do
    inv = Inventory.create(:location => Location.create(:is_remote => false))
    inv.tags.create(:count_1 => 1, :count_2 => 1)
    inv.tags.create(:count_1 => 1, :count_2 => 1)
    inv.tags.create(:count_1 => 1, :count_2 => 1)
    
    assert inv.reload.result_qty == 3
    inv.tags.first.update_attributes(:state => "deleted")

    assert inv.reload.result_qty == 2
    
  end
  
  test "adj_qtys with re_export_qty" do
    inv = Inventory.create(:location => Location.create(:is_remote => true), :inputed_qty => 10)

    assert inv.re_export_offset.nil?
    inv.update_attributes(:re_export_qty => 20)
    assert inv.re_export_offset == 10
  end
  
  test "adj_count_qtys with cost" do
    item = Item.create(:cost => 30)
    inv = Inventory.create(:location => Location.create(:is_remote => false), :item => item)

    inv.tags.create(:count_1 => 1, :count_2 => 2)
    inv.tags.create(:count_1 => 1, :count_2 => 2)
    inv.tags.create(:count_1 => 1, :count_2 => 2)

    inv.reload
    assert inv.counted_1_value == 90
    assert inv.counted_2_value == 180

    item.reload.update_attributes(:cost => 20)
    inv.reload
    assert inv.counted_1_value == 60
    assert inv.counted_2_value == 120

    inv.tags.first.update_attributes(:state => "deleted")
    inv.reload
    assert inv.counted_1_value == 40
    assert inv.counted_2_value == 80

    inv.tags.countable.first.update_attributes(:count_2 => 3)
    inv.reload
    assert inv.counted_2_value == 100
  end

  test "adj_count_qtys with counted_differ" do
    item = Item.create(:cost => 30)
    inv = Inventory.create(:location => Location.create(:is_remote => false), :item => item, :quantity => 4)

    inv.tags.create(:count_1 => 1, :count_2 => 2)
    inv.tags.create(:count_1 => 1, :count_2 => 2)
    inv.tags.create(:count_1 => 1, :count_2 => 2)

    inv.reload
    assert inv.counted_1_value == 90
    assert inv.counted_2_value == 180

    assert inv.counted_1_value_differ == -1 * 30
    assert inv.counted_2_value_differ == 2 * 30
    assert inv.result_value_differ ==  -1 * 30
  end

  test "adj_count_qtys" do
    inv = Inventory.create(:location => Location.create(:is_remote => false))

    inv.tags.create(:count_1 => 1, :count_2 => 2)
    inv.tags.create(:count_1 => 1, :count_2 => 2)
    inv.tags.create(:count_1 => 1, :count_2 => 2)
    inv.reload
    assert inv.counted_1_qty == 3
    assert inv.counted_2_qty == 6

    inv.tags.first.update_attributes(:state => "deleted")
    inv.reload
    assert inv.counted_2_qty == 4

    inv.tags.countable.first.update_attributes(:count_2 => 3)
    inv.reload
    assert inv.counted_2_qty == 5
  end

  test "remote_s" do
    inv1 = Location.create(:is_remote => false).inventories.create
    inv2 = Location.create(:is_remote => true).inventories.create

    assert Inventory.remote_s == [inv2]
  end
  
  test "onsite_s" do
    inv1 = Location.create(:is_remote => false).inventories.create
    inv2 = Location.create(:is_remote => true).inventories.create

    assert Inventory.onsite_s == [inv1]
  end
  
  test "result_value and frozen_value" do
    item = Item.create(:cost => 30, :al_cost => 20)
    inv = item.inventories.create(:quantity => 2, :inputed_qty => 3, :location => Location.create(:is_remote => true))

    inv.reload
    assert inv.frozen_value == 60
    assert inv.result_value == 90

    inv.update_attributes(:quantity => 4, :inputed_qty => 6)
    item.reload.update_attributes(:cost => 40, :al_cost => 50)

    inv.reload
    assert inv.frozen_value == 160
    assert inv.result_value == 240
  end

  test "ao_adj" do
    item = Item.create(:cost => 30, :al_cost => 2)
    inv = item.inventories.create(:quantity => 4, :inputed_qty => 14, :location => Location.create(:is_remote => true))

    assert inv.ao_adj == 10
    assert inv.ao_adj_value == 300

    inv.update_attributes(:inputed_qty => 1)
    assert inv.ao_adj == -3
    assert inv.ao_adj_value == -90
  end
  
  test "need_manually_adj" do
    # is_active, max_quantity, from_al, is_lotted, cost, item_group
    item_group = ItemGroup.create(:item_type_short => 'EA')
    item = Item.create(:is_active => true, :max_quantity => nil, :from_al => true, :is_lotted => false, :cost => 2, :item_group => item_group)

    # is_active, from_al
    location = Location.create(:is_active => true, :from_al => true)
    location.update_attributes(:is_remote => true)

    # ao_adj
    inv = Inventory.create(:item => item, :location => location)
    inv.update_attributes(:quantity => 1, :inputed_qty => 10)

    item.reload
    inv.reload
    location.reload

    # begin test ---------------------------------------------------
    # test ao_adj
    inv.update_attributes(:quantity => 1, :inputed_qty => 1)
    assert !Inventory.need_manually_adj.include?(inv)
    
    inv.update_attributes(:quantity => 0, :inputed_qty => 0)
    assert !Inventory.need_manually_adj.include?(inv)
    inv.update_attributes(:quantity => 1, :inputed_qty => 10)
    
    # test location is_active
    location.update_attributes(:is_active => false)
    assert Inventory.need_manually_adj.include?(inv)
    location.update_attributes(:is_active => true)
    assert !Inventory.need_manually_adj.include?(inv)

    # test location from_al
    location.update_attributes(:from_al => false)
    assert Inventory.need_manually_adj.include?(inv)
    location.update_attributes(:from_al => true)
    assert !Inventory.need_manually_adj.include?(inv)
    
    # test item is_active
    item.update_attributes(:is_active => false)
    assert Inventory.need_manually_adj.include?(inv)
    item.update_attributes(:is_active => true)
    assert !Inventory.need_manually_adj.include?(inv)
    
    # test item max_quantity
    # item.update_attributes(:max_quantity => 1)
    # assert Inventory.need_manually_adj.include?(inv)
    # item.update_attributes(:max_quantity => 0)
    # assert !Inventory.need_manually_adj.include?(inv)
    # item.update_attributes(:max_quantity => nil)
    # assert !Inventory.need_manually_adj.include?(inv)
    # item.update_attributes(:max_quantity => 11)
    # assert !Inventory.need_manually_adj.include?(inv)
    
    item.update_attributes(:from_al => false)
    assert Inventory.need_manually_adj.include?(inv)
    item.update_attributes(:from_al => true)
    assert !Inventory.need_manually_adj.include?(inv)
    
    item.update_attributes(:is_lotted => true)
    assert Inventory.need_manually_adj.include?(inv)
    item.update_attributes(:is_lotted => false)
    assert !Inventory.need_manually_adj.include?(inv)
    
    item.update_attributes(:cost => nil)
    assert Inventory.need_manually_adj.include?(inv)
    item.update_attributes(:cost => 0)
    assert Inventory.need_manually_adj.include?(inv)
    item.update_attributes(:cost => 1)
    assert !Inventory.need_manually_adj.include?(inv)

    item_group.update_attributes(:item_type_short => "NP")
    assert Inventory.need_manually_adj.include?(inv)
    item_group.update_attributes(:item_type_short => "EA")
    assert !Inventory.need_manually_adj.include?(inv)
    
  end

  test "need_adjustment" do
    # is_active, max_quantity, from_al, is_lotted, cost, item_group
    item_group = ItemGroup.create(:item_type_short => 'EA')
    item = Item.create(:is_active => true, :max_quantity => nil, :from_al => true, :is_lotted => false, :cost => 2, :item_group => item_group)

    # is_active, from_al
    location = Location.create(:is_active => true, :from_al => true)
    location.update_attributes(:is_remote => true)

    # ao_adj
    inv = Inventory.create(:item => item, :location => location)
    inv.update_attributes(:quantity => 1, :inputed_qty => 10)

    item.reload
    inv.reload
    location.reload

    # begin test ---------------------------------------------------
    # test ao_adj
    inv.update_attributes(:quantity => 1, :inputed_qty => 10)
    assert Inventory.need_adjustment.include?(inv)

    inv.update_attributes(:quantity => 1, :inputed_qty => 1)
    assert !Inventory.need_adjustment.include?(inv)

    inv.update_attributes(:quantity => 0, :inputed_qty => 0)
    assert !Inventory.need_adjustment.include?(inv)
    inv.update_attributes(:quantity => 1, :inputed_qty => 10)

    # test location is_active
    location.update_attributes(:is_active => false)
    assert !Inventory.need_adjustment.include?(inv)
    location.update_attributes(:is_active => true)
    assert Inventory.need_adjustment.include?(inv)

    # test location from_al
    location.update_attributes(:from_al => false)
    assert !Inventory.need_adjustment.include?(inv)
    location.update_attributes(:from_al => true)
    assert Inventory.need_adjustment.include?(inv)

    # test item is_active
    item.update_attributes(:is_active => false)
    assert !Inventory.need_adjustment.include?(inv)
    item.update_attributes(:is_active => true)
    assert Inventory.need_adjustment.include?(inv)

    # test item max_quantity
    # item.update_attributes(:max_quantity => 1)
    # assert !Inventory.need_adjustment.include?(inv)
    # item.update_attributes(:max_quantity => 0)
    # assert Inventory.need_adjustment.include?(inv)
    # item.update_attributes(:max_quantity => nil)
    # assert Inventory.need_adjustment.include?(inv)
    # item.update_attributes(:max_quantity => 11)
    # assert Inventory.need_adjustment.include?(inv)

    item.update_attributes(:from_al => false)
    assert !Inventory.need_adjustment.include?(inv)
    item.update_attributes(:from_al => true)
    assert Inventory.need_adjustment.include?(inv)

    item.update_attributes(:is_lotted => true)
    assert !Inventory.need_adjustment.include?(inv)
    item.update_attributes(:is_lotted => false)
    assert Inventory.need_adjustment.include?(inv)

    item.update_attributes(:cost => nil)
    assert !Inventory.need_adjustment.include?(inv)
    item.update_attributes(:cost => 0)
    assert !Inventory.need_adjustment.include?(inv)
    item.update_attributes(:cost => 1)
    assert Inventory.need_adjustment.include?(inv)

    item_group.update_attributes(:item_type_short => "NP")
    assert !Inventory.need_adjustment.include?(inv)
    item_group.update_attributes(:item_type_short => "EA")
    assert Inventory.need_adjustment.include?(inv)
  end

  test "his_max" do
    c = new_blank_check
    scope = c.locations.create.inventories

    inv = scope.create(:quantity => 3)
    inv.update_attributes(:quantity => 4)

    c.switch_inv!(2)
    inv.reload.update_attributes(:quantity => 5)
    inv.update_attributes(:quantity => nil)

    c.switch_inv!(3)
    inv.update_attributes(:quantity => 0)

    assert inv.reload.his_max == 4
  end

  test "report_valid" do
    c = new_blank_check
    scope = c.locations.create.inventories

    inv1 = scope.create(:from_al => false)
    inv2 = scope.create(:quantity => 3, :from_al => true)
    inv3 = scope.create(:quantity => 0, :from_al => true)

    assert Inventory.report_valid.count == 2
    assert !Inventory.report_valid.all.include?(inv3)
  end

  test "refresh_item_res_qty" do
    i = Item.create
    i.inventories.create(:location => Location.create(:is_remote => true), :inputed_qty => 2)
    assert i.item_info.res_qty == 2
    
    i2 = Item.create
    i2.inventories.create(:location => Location.create(:is_remote => true), :inputed_qty => 2)
    i2.inventories.create(:location => Location.create(:is_remote => true), :inputed_qty => 3)
    i2.inventories.create(:location => Location.create(:is_remote => true), :inputed_qty => 4)
    
    i2.reload
    assert i2.item_info.res_qty == 9
    assert i2.item_info.remaining.nil?

    i3 = Item.create(:max_quantity => 10)
    i3.inventories.create(:location => Location.create(:is_remote => true), :inputed_qty => 2)
    i3.inventories.create(:location => Location.create(:is_remote => true), :inputed_qty => 3)
    inv = i3.inventories.create(:location => Location.create(:is_remote => true), :inputed_qty => 4)
    
    i3.reload
    assert i3.item_info.res_qty == 9
    assert i3.item_info.remaining == 1
    
    inv.update_attributes(:inputed_qty => inv.inputed_qty + 2)
    i3.reload
    assert i3.item_info.remaining == -1
  end
  
  test "remote_ticket_id" do
    onsite = Location.create(:is_remote => false)
    inv = onsite.inventories.create

    assert inv.remote_ticket_id.nil?
    onsite.update_attributes(:is_remote => true)
    assert inv.reload.remote_ticket_id == "R-#{inv.id}"
    
    remote = Location.create(:is_remote => true)
    inv = remote.inventories.create
    assert inv.remote_ticket_id == "R-#{inv.id}"

    remote.update_attributes(:is_remote => false)
    assert inv.remote_ticket_id.nil?
  end
end


















# == Schema Information
#
# Table name: inventories
#
#  id                     :integer         not null, primary key
#  item_id                :integer
#  location_id            :integer
#  quantity               :integer         default(0)
#  created_at             :datetime
#  updated_at             :datetime
#  from_al                :boolean         default(FALSE)
#  inputed_qty            :integer
#  counted_qty            :integer
#  result_qty             :integer
#  check_id               :integer
#  tag_inited             :boolean         default(FALSE)
#  counted_1_qty          :integer
#  counted_2_qty          :integer
#  counted_1_value        :float
#  counted_2_value        :float
#  result_value           :float
#  frozen_value           :float
#  ao_adj                 :integer
#  ao_adj_value           :float
#  re_export_qty          :integer
#  re_export_offset       :integer
#  his_max                :integer
#  counted_1_value_differ :float
#  counted_2_value_differ :float
#  result_value_differ    :float
#

