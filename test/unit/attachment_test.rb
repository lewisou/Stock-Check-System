require 'test_helper'

class AttachmentTest < ActiveSupport::TestCase

  # test "is_group_xls?" do
  #   assert Attachment.create(:data => group_file).is_group_xls?
  #   assert !Attachment.create(:data => item_file).is_group_xls?
  # end
  # 
  # test 'is_location_xls?' do
  #   assert Attachment.create(:data => location_file).is_location_xls?
  #   assert !Attachment.create(:data => item_file).is_location_xls?
  # end
  # 
  # test 'is_item_xls?' do
  #   assert Attachment.create(:data => item_file).is_item_xls?
  #   assert !Attachment.create(:data => location_file).is_item_xls?
  # end
  # 
  # test 'is_inventory_xls?' do
  #   assert Attachment.create(:data => import_file).is_inventory_xls?
  #   assert !Attachment.create(:data => location_file).is_inventory_xls?
  # end

end



# == Schema Information
#
# Table name: activities
#
#  id          :integer         not null, primary key
#  admin_id    :integer
#  request     :text
#  response    :text
#  ended_at    :datetime
#  finish      :boolean         default(FALSE)
#  created_at  :datetime
#  updated_at  :datetime
#  description :text
#  met         :string(255)
#  check_id    :integer
#

