require 'test_helper'

class TagTest < ActiveSupport::TestCase
  test "in_check scope" do
    c = new_blank_check
    l = c.locations.create
    i = l.inventories.create
    3.times {i.tags.create}
    Tag.create
    
    assert Tag.count == 4
    assert Tag.in_check(c.id).count == 3
  end
  
  test "not_finish" do
    t1 = Tag.create(:count_1 => 1)
    Tag.create(:count_2 => 1)
    Tag.create
    
    assert Tag.not_finish(1).count == 2
    assert Tag.not_finish(2).count == 2
    assert Tag.count == 3
    assert !Tag.not_finish(1).include?(t1)
  end
  
  test "finish scope" do
    t1 = Tag.create(:count_1 => 1)
    Tag.create(:count_2 => 1)
    Tag.create
    
    assert Tag.finish(1).count == 1
    assert Tag.finish(2).count == 1
    assert Tag.count == 3
    assert Tag.finish(1).include?(t1)
  end

  test "counted_by scope" do
    c1 = Counter.create
    c2 = Counter.create

    l1 = Location.create
    l2 = Location.create

    t1 = l1.inventories.create.tags.create
    t2 = l2.inventories.create.tags.create

    l1.assigns.create(:counter => c1, :count => 1)
    l1.assigns.create(:counter => c2, :count => 2)

    l2.assigns.create(:counter => c1, :count => 2)
    l2.assigns.create(:counter => c2, :count => 2)

    assert Tag.counted_by("#{c1.id}_1") == [t1]
    assert Tag.counted_by("#{c1.id}_2") == [t2]
    assert Tag.counted_by("#{c2.id}_1").count == 0
    assert Tag.counted_by("#{c2.id}_2").include?(t1)
    assert Tag.counted_by("#{c2.id}_2").include?(t2)
    assert Tag.count == 2

  end

  test "tole_q_or_v scope" do
    scope = Item.create(:cost => 1).inventories.create.tags
    
    scope.create(:count_1 => 100, :count_2 => 110)
    scope.create(:count_1 => 100, :count_2 => 120)
    scope.create(:count_1 => 100, :count_2 => 130)
    scope.create(:count_1 => 100, :count_2 => 140)
    scope.create(:count_1 => 100, :count_2 => 150)
    scope.create(:count_1 => 100)
    scope.create()
    
    assert Tag.tole_q_or_v(50, 51).count == 1
    assert Tag.tole_q_or_v(50.1, 51).count == 0

    assert Tag.tole_q_or_v(51, 50).count == 1
    assert Tag.tole_q_or_v(50, 50).count == 1
    
    assert Tag.tole_q_or_v(51, 51).count == 0
    
    assert Tag.tole_q_or_v(40, 41).count == 2
    assert Tag.tole_q_or_v(41, 40).count == 2
    assert Tag.tole_q_or_v(40, 40).count == 2
    
    assert Tag.tole_q_or_v(41, 41).count == 1
  end

  test "tolerance_q scope" do
    Tag.create(:count_1 => 100, :count_2 => 110)
    Tag.create(:count_1 => 100, :count_2 => 120)
    Tag.create(:count_1 => 100, :count_2 => 130)
    Tag.create(:count_1 => 100, :count_2 => 140)
    Tag.create(:count_1 => 100, :count_2 => 150)
    Tag.create(:count_1 => 100)
    Tag.create()

    assert Tag.tolerance_q(50.1).count == 0
    assert Tag.tolerance_q(50).count == 1
    assert Tag.tolerance_q(40).count == 2

    assert Tag.tolerance_q(30).count == 3
    assert Tag.tolerance_q(25).count == 3
    
    assert Tag.tolerance_q(20).count == 4
    assert Tag.tolerance_q(15).count == 4
  end

  test "tolerance_v" do
    scope = Item.create(:cost => 1).inventories.create.tags
    
    scope.create(:count_1 => 100, :count_2 => 110)
    scope.create(:count_1 => 100, :count_2 => 120)
    scope.create(:count_1 => 100, :count_2 => 130)
    scope.create(:count_1 => 100, :count_2 => 140)
    scope.create(:count_1 => 100, :count_2 => 150)
    scope.create(:count_1 => 100)
    scope.create()

    assert Tag.tolerance_v(50.1).count == 0
    assert Tag.tolerance_v(50).count == 1
    assert Tag.tolerance_v(40).count == 2

    assert Tag.tolerance_v(30).count == 3
    assert Tag.tolerance_v(25).count == 3
    
    assert Tag.tolerance_v(20).count == 4
    assert Tag.tolerance_v(15).count == 4
  end

  test "adj_inventory" do
    c = new_blank_check
    c.item_groups.create
    
    i = c.item_groups.first.items.create
    l = c.locations.create
    inv = l.inventories.create(:item => i)

    new_i = c.item_groups.first.items.create
    new_l = c.locations.create

    t = inv.tags.create
    t.location_id = new_l.id
    t.item_id = new_i.id
    t.save
    
    assert Inventory.count == 2
    assert t.inventory.id != inv.id
    
    t2 = Tag.create(:item_id => i, :location_id => l)
    assert t2.inventory == inv
  end
  
  test "final_count" do
    assert Tag.create(:count_1 => 1, :count_2 => 1).final_count == 1
    assert Tag.create(:count_1 => 1, :count_2 => 2).final_count == 1
    assert Tag.create(:count_1 => 1, :count_2 => 2, :count_3 => 3).final_count == 3
    assert Tag.create(:count_1 => 1).final_count == nil
    assert Tag.create(:count_2 => 2).final_count == nil
    assert Tag.create.final_count == nil
  end

  test "counted_value" do
    scope = Item.create(:cost => 1).inventories.create.tags
    
    assert scope.create(:count_1 => 2, :count_2 => 2).counted_value == 2
    assert scope.create.final_count == nil

    nil_scope = Item.create(:cost => nil).inventories.create.tags
    assert nil_scope.create(:count_1 => 2, :count_2 => 2).counted_value == nil
  end

  test "count & value differ" do
    scope = Item.create(:cost => 1).inventories.create.tags
    
    assert scope.create(:count_1 => 1, :count_2 => 2).count_differ == 100
    assert scope.create(:count_1 => 5, :count_2 => 2).count_differ == 60
    assert scope.create.count_differ == nil

    assert scope.create(:count_1 => 1, :count_2 => 2).value_differ == 1
    assert scope.create(:count_1 => 5, :count_2 => 2).value_differ == 3
    assert scope.create.count_differ == nil
    
  end
end

# == Schema Information
#
# Table name: tags
#
#  id           :integer         not null, primary key
#  count_1      :integer
#  count_2      :integer
#  count_3      :integer
#  created_at   :datetime
#  updated_at   :datetime
#  inventory_id :integer
#  sloc         :string(255)
#
