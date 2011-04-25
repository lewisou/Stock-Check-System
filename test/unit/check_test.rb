require 'test_helper'

class CheckTest < ActiveSupport::TestCase
  test "current check" do
    3.times { Check.new().save(:validate => false) }

    c = Check.last
    c.make_current!
    
    assert Check.find(c.id).current == true
    assert Check.where(:current => true).count == 1
    
    c = Check.first
    c.make_current!
    
    assert c.current == true
    assert Check.where(:current => true).count == 1

  end

  test "curr_s scope" do
    3.times { Check.new().save(:validate => false) }

    c = Check.last
    c.make_current!

    assert Check.curr_s.first == c
    assert Check.curr_s.count == 1
  end

  test "refresh_item_and_group" do
    # launch refresh_item_and_group in before filter
    c = new_check
    c.save(:validate => false)

    assert c.item_groups.count == 33
    assert ItemGroup.count == 33
    assert c.items.count == 22
    assert Item.count == 22
  end

  test "init_colors" do
    c = Check.new()
    c.save(:validate => false)
    
    assert c.color_1 == 'B4E2D4'
    assert c.color_2 == 'F3C4C8'
    assert c.color_3 == 'EADFD2'
    
    c.color_1 = '1'
    c.color_2 = '2'
    c.color_3 = '3'
    c.save(:validate => false)
    
    assert c.color_1 != 'B4E2D4'
    assert c.color_2 != 'F3C4C8'
    assert c.color_3 != 'EADFD2'
  end

  test "refresh_location" do
    c = new_check
    c.save(:validate => false)
    
    assert c.locations.count == 2
    assert Location.count == 2
  end

  test "refresh_inventories" do
    c = new_check
    c.save(:validate => false)

    assert Inventory.in_check(c.id).count == 22
  end
  
  test "init_properties before create" do
    c = Check.new
    c.save(:validate => false)
    
    assert c.state == 'open'

    c.state = 'whatever'
    c.save

    assert c.state != 'open'
  end
  
  test "generate_xls" do
    c = new_check
    c.save(:validate => false)
    c.items.each {|i| i.from_al = false, i.save(:validate => false)}
    c.generate_xls
    c.save(:validate => false)

    c = Check.find(c.id)
    assert c.location_xls.data_file_size > 0
    assert c.item_xls.data_file_size > 0
    assert c.inv_adj_xls.data_file_size > 0
  end
  
  test "finish_count?" do
    c = new_check
    c.save(:validate => false)
    
    Tag.update_all(:count_1 => 1)
    Tag.update_all(:count_2 => 2)
    
    assert c.finish_count? 
    
    Tag.update_all(:count_1 => nil)
    Tag.update_all(:count_2 => nil)
    
    assert !c.finish_count?
  end
end
