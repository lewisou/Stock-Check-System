require 'test_helper'
 
class AssignTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "in check" do
    c = Check.new()
    c.save(:validate => false)
    l = c.locations.create
    
    3.times { l.assigns.create() }
    Assign.create()

    assert Assign.in_check(c.id).count == 3
  end

end