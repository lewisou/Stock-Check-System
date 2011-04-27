require 'test_helper'

class CounterTest < ActiveSupport::TestCase

  test "refresh_assigns" do
    c = Counter.create
    3.times {Assign.create(:location => Location.create, :count => 1)}
    
    c.new_assigns = Assign.all
    c.curr_check = ch = Check.create
    c.save #launch refresh_assigns

    assert Counter.find(c.id).assigns.in_check(ch.id) == Assign.all
  end

  test "check_location_by_count?" do
    c = Check.new
    c.save(:validate => false)
    
    l = c.locations.create
    l2 = c.locations.create
    l3 = c.locations.create

    c = Counter.create
    
    a = Assign.create(:location => l, :counter => c, :count => 1)
    a2 = Assign.create(:location => l2, :counter => c, :count => 2)

    assert c.check_location_by_count?(l, 1)
    assert !c.check_location_by_count?(l2, 1)
    assert !c.check_location_by_count?(l3, 1)
  end

  test "check_location?" do
    c = Check.new
    c.save(:validate => false)
    
    l = c.locations.create
    l2 = c.locations.create
    l3 = c.locations.create
    c = Counter.create

    a = Assign.create(:location => l, :counter => c, :count => 1)
    a2 = Assign.create(:location => l2, :counter => c, :count => 2)

    assert c.check_location?(l)
    assert c.check_location?(l2)
    assert !c.check_location?(l3)
  end
  
  test "counted_bys" do
    3.times {|i| Counter.create(:name => "name_#{i}")}
    
    rs = []
    2.times do |i|
      Counter.all.each do |c| 
        rs << ["Count #{i + 1} by #{c.name}", "#{c.id}_#{i + 1}"]
      end
    end

    assert Counter.counted_bys == rs
  end
end

# == Schema Information
#
# Table name: counters
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  description :text
#

