require 'test_helper'

class LocationInfoTest < ActiveSupport::TestCase

  test "refresh_sum_info" do
    location = Location.create(:is_remote => true)
    item = Item.create(:cost => 2.1, :from_al => true)
    
    location.inventories.create(:item => item, :quantity => 2, :inputed_qty => 3)
    location.inventories.create(:item => item, :quantity => 2, :inputed_qty => 3)
    
    assert location.location_info.sum_frozen_qty == 4
    assert location.location_info.sum_result_qty == 6
    assert location.location_info.sum_frozen_value == 8.4
    assert location.location_info.sum_result_value == 12.6

  end
end

