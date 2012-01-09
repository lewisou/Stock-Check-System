require 'test_helper'

class ItemInfoTest < ActiveSupport::TestCase

  test "refresh_remote_info" do
    item = Item.create(:cost => 2.1, :from_al => true)
    item.inventories.remote_s.create(:quantity => 2, :inputed_qty => 3, :location => Location.create(:is_remote => true))
    item.inventories.remote_s.create(:quantity => 2, :inputed_qty => 3, :location => Location.create(:is_remote => true))
    
    assert item.item_info.sum_remote_frozen_qty == 4
    assert item.item_info.sum_remote_result_qty == 6
    assert item.item_info.sum_remote_frozen_value == 8.4
    assert item.item_info.sum_remote_result_value == 12.6
  end
end



# == Schema Information
#
# Table name: item_infos
#
#  id                      :integer         not null, primary key
#  res_qty                 :integer
#  item_id                 :integer
#  created_at              :datetime
#  updated_at              :datetime
#  remaining               :integer
#  sum_remote_frozen_qty   :integer
#  sum_remote_result_qty   :integer
#  sum_remote_frozen_value :float
#  sum_remote_result_value :float
#

