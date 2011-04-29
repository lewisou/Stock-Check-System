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
#

