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

  test "refresh_re_export_qtys from mising inventory" do
    c = new_check
    c.save(:validate => false)
    assert c.inventories.count == 22

    c.re_export_qtys_xls = reimport_file
    c.save
    assert c.inventories.count == 23

    new_inv = c.inventories.includes(:item).includes(:location).where(:items => {:code => "104-102-011"}, :locations => {:code => "MR"}).first
    assert new_inv.try(:quantity) == 0
    assert new_inv.try(:re_export_qty) == 49
    # 
    where = c.inventories.includes(:item).where(:items => (:code.eq % "04/CM002" | :code.eq % "04/CM003"))
    assert where.count == 2
    assert where.where(:items => {:code => '04/CM002'}).first.quantity == 1
    assert where.where(:items => {:code => '04/CM003'}).first.quantity == 15
    assert where.where(:items => {:code => '04/CM002'}).first.re_export_qty == 2
    assert where.where(:items => {:code => '04/CM003'}).first.re_export_qty == 14

    # mising inventory
    c.re_export_qtys_xls = import_file
    c.save

    where = c.inventories.includes(:item).where(:items => (:code.eq % "04/CM002" | :code.eq % "04/CM003"))
    assert where.count == 2
    assert where.where(:items => {:code => '04/CM002'}).first.quantity == 1
    assert where.where(:items => {:code => '04/CM003'}).first.quantity == 15
    assert where.where(:items => {:code => '04/CM002'}).first.re_export_qty == 1
    assert where.where(:items => {:code => '04/CM003'}).first.re_export_qty == 15
    
    new_inv = c.inventories.includes(:item).includes(:location).where(:items => {:code => "104-102-011"}, :locations => {:code => "MR"}).first
    assert new_inv.try(:quantity) == 0
    assert new_inv.try(:re_export_qty) == 0

  end

  test "switch_inv with reimport_inv_xls" do
    c = new_blank_check
    c.save

    whe = c.inventories.includes(:item).where(:items => (:code.eq % "04/CM002" | :code.eq % "04/CM003"))
    assert whe.count == 0
    assert c.reload.import_time == 1

    c = new_check
    c.save(:validate => false)
    c.locations.update_all(:is_remote => false)
    
    assert c.inventories.count == 22
    assert c.reload.import_time == 1

    c.reimport_inv_xls = reimport_file
    c.switch_inv!(2)
    assert c.reload.import_time == 2
    assert c.inventories.count == 23

    where = c.inventories.includes(:item).where(:items => (:code.eq % "04/CM002" | :code.eq % "04/CM003"))
    assert where.count == 2
    assert where.where(:items => {:code => '04/CM002'}).first.quantity == 2
    assert where.where(:items => {:code => '04/CM003'}).first.quantity == 14

    new_inv = c.inventories.includes(:item).includes(:location).where(:items => {:code => "104-102-011"}, :locations => {:code => "MR"}).first
    assert new_inv.try(:quantity) == 49
    
    c.reimport_inv_xls = import_file
    c.switch_inv!(3)
    assert c.reload.import_time == 3
    assert c.inventories.count == 23
    where = c.inventories.includes(:item).where(:items => (:code.eq % "04/CM002" | :code.eq % "04/CM003"))
    assert where.count == 2
    assert where.where(:items => {:code => '04/CM002'}).first.quantity == 1
    assert where.where(:items => {:code => '04/CM003'}).first.quantity == 15

    new_inv = c.inventories.includes(:item).includes(:location).where(:items => {:code => "104-102-011"}, :locations => {:code => "MR"}).first
    assert new_inv.try(:quantity) == 0
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
    assert Item.all.map(&:is_lotted).include?(true)
    assert Item.all.map(&:is_lotted).include?(false)
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

  test "generate_xls" do
    c = new_check
    c.save(:validate => false)
    c.items.each {|i| i.from_al = false, i.save(:validate => false)}
    c.generate_xls
    c.save(:validate => false)

    c.reload
    assert c.inv_adj_xls.data_file_size > 0
    assert c.manual_adj_xls.data_file_size > 0
  end
  
  test "finish_count?" do
    c = new_check
    c.save(:validate => false)
    c.locations.first.inventories.create.tags.create
    c.locations.each {|l| l.update_attributes(:is_remote => false)}
    
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
    c.locations.each {|l| l.update_attributes(:is_remote => false)}

    Tag.update_all(:count_1 => 1)
    assert c.finish_count_in(1)
    assert !c.finish_count_in(2)

    Tag.update_all(:count_2 => 1)
    assert c.finish_count_in(2)
  end
  
  test "count_time_value" do
    c = new_blank_check
    inv = c.item_groups.create.items.create(:cost => 2).inventories.create(:location => c.locations.create(:is_remote => false))
    3.times {|i| inv.tags.create(:count_1 => i, :count_2 => (i + 1))}

    inv = c.item_groups.create.items.create(:cost => 2).inventories.create(:location => c.locations.create(:is_remote => true))
    3.times {|i| inv.tags.create(:count_1 => i, :count_2 => (i + 1))}

    assert c.count_time_value(1) == 6
    assert c.count_time_value(2) == 12
  end
  
  test "counted_value" do
    c = new_blank_check
    inv = c.item_groups.create.items.create(:cost => 2).inventories.create(:location => c.locations.create(:is_remote => false))
    3.times {|i| inv.tags.create(:count_1 => 1, :count_2 => 1)}
    
    inv = c.item_groups.create.items.create(:cost => 2).inventories.create(:location => c.locations.create(:is_remote => true))
    3.times {|i| inv.tags.create(:count_1 => 1, :count_2 => 1)}

    assert c.counted_value == 6
  end
  
  test "frozen_value" do
    c = new_blank_check
    c.item_groups.create.items.create(:cost => 1).inventories.create(:location => c.locations.create, :quantity => 1)
    c.item_groups.create.items.create(:cost => 1).inventories.create(:location => c.locations.create, :quantity => 2)

    assert c.reload.frozen_value == 3
  end

  test "switch_inv" do
    c = new_blank_check
    inv = c.locations.create.inventories.create(:quantity => 1, :from_al => false)
    inv2 = c.locations.create.inventories.create(:quantity => 1, :from_al => false)

    c.reload.switch_inv!(2)
    inv.update_attributes(:quantity => 2, :from_al => true)
    inv2.update_attributes(:quantity => 2, :from_al => true)

    c.reload.switch_inv!(3)
    inv.update_attributes(:quantity => 3, :from_al => false)
    inv2.update_attributes(:quantity => 3, :from_al => false)
    inv3 = c.locations.create.inventories.create(:quantity => 23, :from_al => true)

    3.times do |t|
      c.reload.switch_inv!(t + 1)

      assert inv.reload.quantity == (t + 1)
      assert inv.reload.from_al == (((t + 5) % 2 == 0) ? true : false)

      assert inv2.reload.quantity == (t + 1)
      assert inv2.reload.from_al == (((t + 5) % 2 == 0) ? true : false)
      
      if t < 2
        assert inv3.reload.quantity == 0
        assert inv3.reload.from_al == false
      else
        assert inv3.reload.quantity == 23
        assert inv3.reload.from_al == true
      end
    end
    
    c.reload.switch_inv!(1)
    inv3.reload.quantity == 0
    inv3.reload.from_al == false
  end
  
  test "history scope" do
    new_blank_check.update_attributes(:state => "open")
    new_blank_check.update_attributes(:state => "cancel")
    new_blank_check.update_attributes(:state => "complete")
    new_blank_check.update_attributes(:state => nil)
    new_blank_check.update_attributes(:state => "archive")
    new_blank_check.update_attributes(:state => "archive")

    assert Check.history.count == 2
  end

  test "create_update_from_row" do
    c = new_blank_check
    item = c.item_groups.create.items.create(:code => '1.300')
    loc = c.locations.create(:code => 'CA')
    c.locations.create(:code => 'CD')
    c.locations.create(:code => 'CX')

    inv = c.inventories.create(:item => item, :location => loc, :quantity => 30)
    assert inv.reload.from_al == false

    c.create_update_from_row ["1.300", "CA"] + [""] * 13 + [60], :from_al => :keep
    assert c.inventories.count == 1
    assert inv.reload.quantity == 60
    assert inv.reload.from_al == false

    c.create_update_from_row ["1.300", "CA"] + [""] * 13 + [60]
    assert c.inventories.count == 1
    assert inv.reload.quantity == 60
    assert inv.reload.from_al == true

    inv = c.create_update_from_row ["1.300", "CD"] + [""] * 13 + [60], :from_al => :keep
    assert c.inventories.count == 2
    assert c.import_time == 1
    assert inv.reload.from_al == false
    
    inv = c.create_update_from_row ["1.300", "CX"] + [""] * 13 + [60]
    assert c.inventories.count == 3
    assert c.import_time == 1
    assert inv.reload.from_al == true
  end

  test "switch_inv! 2" do
    c = new_blank_check
    lo = c.locations.create

    inv = lo.inventories.create(:quantity => 20)

    c.switch_inv!(2)
    assert inv.reload.quantity == 0

    c.switch_inv!(1)
    assert inv.reload.quantity == 20
  end

  test "count_time_value with deleted_tag" do
    c = new_blank_check
    c.locations.create(:is_remote => false).inventories.create(:item => Item.create(:cost => 2)).tags.create(:count_1 => 1, :count_2 => 1)
    c.locations.create(:is_remote => false).inventories.create(:item => Item.create(:cost => 2)).tags.create(:count_1 => 1, :count_2 => 1)
    tag = c.locations.create(:is_remote => false).inventories.create(:item => Item.create(:cost => 2)).tags.create(:count_1 => 1, :count_2 => 1)

    c.locations.create(:is_remote => true).inventories.create(:item => Item.create(:cost => 2)).tags.create(:count_1 => 1, :count_2 => 1)

    assert c.reload.count_time_value(1) == 6

    tag.reload.update_attributes(:state => 'deleted')
    assert c.reload.count_time_value(1) == 4
  end
  
  test "final_value" do
    c = new_blank_check
    c.locations.create(:is_remote => false).inventories.create(:item => Item.create(:cost => 2)).tags.create(:count_1 => 2, :count_2 => 2)
    c.locations.create(:is_remote => true).inventories.create(:item => Item.create(:cost => 3), :inputed_qty => 10)

    assert c.reload.final_value == 34
  end
  
  test "ao_adj_value & ao_adj_abs_value" do
    c = new_blank_check
    # -5 qty
    c.locations.create(:is_remote => false).inventories.create(:item => Item.create(:cost => 2), :quantity => 15).tags.create(:count_1 => 10, :count_2 => 10)
    # +5 qty
    c.locations.create(:is_remote => true).inventories.create(:item => Item.create(:cost => 3), :quantity => 5, :inputed_qty => 10)

    assert c.reload.ao_adj_value == -5 * 2 + 5 * 3
    assert c.reload.ao_adj_abs_value == 5 * 2 + 5 * 3
  end

  test "inputed_value" do
    c = new_blank_check
    c.locations.create(:is_remote => false).inventories.create(:item => Item.create(:cost => 2)).tags.create(:count_1 => 2, :count_2 => 2)
    c.locations.create(:is_remote => true).inventories.create(:item => Item.create(:cost => 3), :inputed_qty => 10)
    c.locations.create(:is_remote => true).inventories.create(:item => Item.create(:cost => 3), :inputed_qty => 10)

    assert c.reload.inputed_value == 60
  end

  test "remote_frozen_value" do
    c = new_blank_check
    c.item_groups.create.items.create(:cost => 2.1).inventories.create(:location => c.locations.create(:is_remote => false), :quantity => 2)
    c.item_groups.create.items.create(:cost => 4.1).inventories.create(:location => c.locations.create(:is_remote => true), :quantity => 3)

    assert c.reload.remote_frozen_value == 12.3
  end
  
  test "onsite_frozen_value" do
    c = new_blank_check
    c.item_groups.create.items.create(:cost => 2.1).inventories.create(:location => c.locations.create(:is_remote => false), :quantity => 2)
    c.item_groups.create.items.create(:cost => 4).inventories.create(:location => c.locations.create(:is_remote => true), :quantity => 3)

    assert c.reload.onsite_frozen_value == 4.2
  end
  
  test "adj_instruction" do
    c = new_blank_check
    c.instruction_file = File.new("#{Rails.root.to_s}/test/files/reimport_inv.xls")
    
    c.save
    
    assert c.instruction != nil
    
    c = Check.find(c.id)
    c.save
    assert c.instruction != nil
  end
  
  test "opt_s" do
    new_blank_check
    b = new_blank_check
    c = new_blank_check
    c.make_current!
    
    assert = Check.opt_s.first == nil
    c.update_attributes(:state => "open")
    assert = Check.opt_s.first == c
    c.update_attributes(:state => "complete")
    assert = Check.opt_s.first == c

    b.make_current!
    assert = Check.opt_s.first == nil
  end
  
  test "set_remotes" do
    c = new_blank_check
    3.times {c.locations.create}
    
    l = Location.first
    c.set_remotes [l.id]
    
    assert c.locations.count == 3
    assert c.locations.where(:is_remote => false).count == 2
    assert c.locations.where(:is_remote => true).count == 1
    assert l.reload.is_remote == true
  end
  
  test "archive!" do
    Admin.all.each do |adm|
      adm.destroy
    end
    assert Admin.count == 0
    
    a = new_admin 1, Role.find_by_code("organizer")
    b = new_admin 2, Role.find_by_code("controller")
    assert Admin.count == 2
    
    c = new_blank_check
    c.archive!

    assert c.reload.state == "archive"
    assert Check.opt_s.count == 0
    assert Check.curr_s.count == 0
    assert Admin.count == 2
    
    assert a.reload.roles == []
    assert b.reload.roles == [Role.find_by_code("controller")]

  end

  test "can_complete?" do
    c = new_blank_check
    assert !c.can_complete?
    c.update_attributes(:final_inv => true)
    assert !c.can_complete?
    c.update_attributes(:state => 'open')
    assert c.can_complete?

    t = c.locations.create(:is_remote => false).inventories.create.tags.create
    assert !c.can_complete?
    t.update_attributes(:count_1 => 2)
    assert !c.can_complete?
    t.update_attributes(:count_2 => 2)
    assert c.can_complete?    
    
    inv = c.locations.create(:is_remote => true).inventories.create
    assert !c.can_complete?
    inv.update_attributes(:inputed_qty => 3)
    assert c.can_complete?
  end
  
  test "duration" do
    Timecop.freeze(Time.now) do    
      c = new_blank_check

      c.update_attributes(:start_time => nil, :end_time => nil)
      assert c.duration == 0
      c.update_attributes(:start_time => Time.now + 1.days, :end_time => nil)
      assert c.duration == 0
      c.update_attributes(:start_time => Time.now, :end_time => nil)
      assert c.duration == 0
      c.update_attributes(:start_time => Time.now - 1.days, :end_time => nil)
      assert c.duration > 0

      c.update_attributes(:start_time => Time.now, :end_time => Time.now + 2.days)
      assert c.duration > 0
      c.update_attributes(:start_time => Time.now, :end_time => Time.now - 1.days)
      assert c.duration == 0
      c.update_attributes(:start_time => Time.now, :end_time => Time.now)
      assert c.duration == 0

      c.update_attributes(:start_time => nil, :end_time => Time.now)
      assert c.duration == 0

    end
  end
  
  test "refresh_qtys_from_xls" do
    c = new_check
    c.save(:validate => false)
    c.inventories.update_all(:from_al => false)

    c.refresh_qtys_from_xls reimport_file, :re_export_qty, :from_al => :keep
    assert c.inventories.count == 23
    assert c.inventories.map(&:from_al).uniq == [false]
    assert c.inventories.where(:re_export_qty.gt => 0).count > 0
    assert c.inventories.where(:quantity.gt => 0).count > 0

    c = new_check
    c.save(:validate => false)
    c.inventories.update_all(:from_al => false)

    c.inventories.update_all(:quantity => 0)
    c.refresh_qtys_from_xls reimport_file
    assert c.inventories.count == 23
    assert c.inventories.map(&:from_al).uniq == [true]
    assert c.inventories.where(:re_export_qty.gt => 0).count == 0
    assert c.inventories.where(:quantity.gt => 0).count > 0
  end
end










# == Schema Information
#
# Table name: checks
#
#  id                :integer         not null, primary key
#  state             :string(255)     default("init")
#  created_at        :datetime
#  updated_at        :datetime
#  current           :boolean         default(FALSE)
#  description       :text
#  admin_id          :integer
#  location_xls_id   :integer
#  inv_adj_xls_id    :integer
#  item_xls_id       :integer
#  color_1           :string(255)
#  color_2           :string(255)
#  color_3           :string(255)
#  generated         :boolean         default(FALSE)
#  import_time       :integer         default(1)
#  instruction_id    :integer
#  start_time        :date
#  end_time          :date
#  credit_v          :float
#  credit_q          :float
#  al_account        :text
#  manual_adj_xls_id :integer
#  final_inv         :boolean         default(FALSE)
#

