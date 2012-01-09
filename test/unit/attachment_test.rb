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
# Table name: attachments
#
#  id                :integer         not null, primary key
#  data_file_name    :string(255)
#  data_content_type :string(255)
#  data_file_size    :integer
#  data_updated_at   :datetime
#  created_at        :datetime
#  updated_at        :datetime
#

