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
  
  test "generate!" do
    c = new_check
    c.save(:validate => false)
    
    assert Tag.in_check(c.id).count == 0
    c.locations.update_all(:is_remote => false)

    inv = c.inventories.first
    inv.location.update_attributes(:code => 'CA')
    inv.item.update_attributes(:inittags => 'CAH17, CAH18')
    
    c.generate!
    assert Tag.in_check(c.id).count == c.inventories.count + 1

    c.generate!
    assert Tag.in_check(c.id).count == c.inventories.count + 1
  end

  test "reimport" do
    c = new_blank_check
    c.reimport_inv_xls = File.new("#{Rails.root.to_s}/test/files/reimport_inv.xls")
    c.save
    
    whe = c.inventories.includes(:item).where(:items => (:code.eq % "04/CM002" | :code.eq % "04/CM003"))
    assert whe.count == 0
    
    c = new_check
    c.save(:validate => false)
    c.locations.update_all(:is_remote => false)
        
    assert c.inventories.count == 22
    
    c.reimport_inv_xls = File.new("#{Rails.root.to_s}/test/files/reimport_inv.xls")
    c.save
    
    assert c.inventories.count == 23
    
    where = c.inventories.includes(:item).where(:items => (:code.eq % "04/CM002" | :code.eq % "04/CM003"))
    assert where.count == 2
    where.where(:items => {:code => '04/CM002'}).first.quantity == 2
    where.where(:items => {:code => '04/CM003'}).first.quantity == 14
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
    c.locations.update_all(:is_remote => false)
    
    assert c.item_groups.count == 33
    assert ItemGroup.count == 33
    assert c.items.count == 22
    assert Item.count == 22
    assert !Item.all.map(&:is_active).include?(nil)
    assert Item.all.map(&:is_active).include?(true)
  end
  
  test "refresh_item_and_group will load shelf locations" do
    c = new_check
    c.save(:validate => false)
    

    assert Item.where(:inittags.not_eq => nil).count > 0
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
  
  test "refresh_inventories will not create default tags" do
    c = new_check
    c.save(:validate => false)
    c.locations.update_all(:is_remote => false)
        
    assert Tag.in_check(c.id).count == 0
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
    c.locations.first.inventories.create.tags.create

    Tag.update_all(:count_1 => 1)
    Tag.update_all(:count_2 => 2)

    assert c.finish_count?
    
    Tag.update_all(:count_1 => nil)
    Tag.update_all(:count_2 => nil)
    
    assert !c.finish_count?
  end
  
  test "finish_count_in" do
    c = new_check
    c.save(:validate => false)
    c.locations.first.inventories.create.tags.create

    Tag.update_all(:count_1 => 1)
    assert c.finish_count_in(1)
    assert !c.finish_count_in(2)

    Tag.update_all(:count_2 => 1)
    assert c.finish_count_in(2)
  end
  
  test "total count 1 & 2 value" do
    c = new_blank_check
    inv = c.item_groups.create.items.create(:cost => 1).inventories.create(:location => c.locations.create)
    3.times {|i| inv.tags.create(:count_1 => i, :count_2 => (i + 1))}

    assert c.total_count_value(1) == 3
    assert c.total_count_value(2) == 6
  end
  
  test "total_count_final_value" do
    c = new_blank_check
    inv = c.item_groups.create.items.create(:cost => 1).inventories.create(:location => c.locations.create)
    3.times {|i| inv.tags.create(:count_1 => 1, :count_2 => 1)}
    
    assert c.total_count_final_value == 3
  end
  
  test "total frozen value" do
    c = new_blank_check
    c.item_groups.create.items.create(:cost => 1).inventories.create(:location => c.locations.create, :quantity => 1)
    c.item_groups.create.items.create(:cost => 1).inventories.create(:location => c.locations.create, :quantity => 2)
    
    assert c.total_frozen_value == 3
  end

  test "switch inventory" do
    c = new_blank_check
    inv = c.locations.create.inventories.create(:quantity => 1)
    
    c.update_attributes(:import_time => 2)
    inv.update_attributes(:quantity => 2)
    
    c.update_attributes(:import_time => 3)
    inv.update_attributes(:quantity => 3)

    c.update_attributes(:import_time => 1)
    inv2 = c.locations.create.inventories.create(:quantity => 1)
    
    c.update_attributes(:import_time => 2)
    inv2.update_attributes(:quantity => 2)
    
    c.update_attributes(:import_time => 3)
    inv2.update_attributes(:quantity => 3)

    3.times do |t|
      c.reload.update_attributes(:import_time => t + 1)
      assert inv.reload.quantity == (t + 1)
      assert inv2.reload.quantity == (t + 1)
    end
  end
  
  test "history scope" do
    new_blank_check.update_attributes(:current => true)
    new_blank_check.update_attributes(:current => false)
    new_blank_check.update_attributes(:current => false)
    
    assert Check.history.count == 2
  end
  
  test "create_update_from_row" do
    c = new_blank_check
    item = c.item_groups.create.items.create(:code => '1.300')
    loc = c.locations.create(:code => 'CA')
    c.locations.create(:code => 'CD')
    
    c.inventories.create(:item => item, :location => loc, :quantity => 30)
    
    c.create_update_from_row ["1.300", "CA"] + [""] * 5 + [60]
    assert c.inventories.count == 1
    
    c.create_update_from_row ["1.300", "CD"] + [""] * 5 + [60]
    assert c.inventories.count == 2
  end
  
  test "after save switch_inv" do
    c = new_blank_check
    lo = c.locations.create
    
    inv = lo.inventories.create(:quantity => 20)
    
    c.update_attributes(:import_time => 2)
    assert inv.reload.quantity.nil?

    c.update_attributes(:import_time => 1)
    assert inv.reload.quantity == 20
  end
end



# == Schema Information
#
# Table name: checks
#
#  id              :integer         not null, primary key
#  state           :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  current         :boolean         default(FALSE)
#  description     :text
#  admin_id        :integer
#  location_xls_id :integer
#  inv_adj_xls_id  :integer
#  item_xls_id     :integer
#  color_1         :string(255)
#  color_2         :string(255)
#  color_3         :string(255)
#  generated       :boolean         default(FALSE)
#  import_time     :integer         default(1)
#

