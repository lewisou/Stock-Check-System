require 'spec_helper'

describe ItemGroup do
  pending "add some examples to (or delete) #{__FILE__}"
end


# == Schema Information
#
# Table name: item_groups
#
#  id              :integer         not null, primary key
#  name            :text
#  item_type       :string(255)
#  item_type_short :string(255)
#  is_purchased    :boolean
#  is_sold         :boolean
#  is_used         :boolean
#  is_active       :boolean
#  created_at      :datetime
#  updated_at      :datetime
#  check_id        :integer
#

