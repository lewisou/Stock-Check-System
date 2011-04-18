require 'spec_helper'

describe Inventory do
  pending "add some examples to (or delete) #{__FILE__}"
end



# == Schema Information
#
# Table name: inventories
#
#  id             :integer         not null, primary key
#  item_id        :integer
#  location_id    :integer
#  quantity       :integer
#  created_at     :datetime
#  updated_at     :datetime
#  from_al        :boolean         default(FALSE)
#  cached_counted :integer
#

