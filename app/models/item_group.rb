class ItemGroup < ActiveRecord::Base
  belongs_to :check
  has_many :items
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

