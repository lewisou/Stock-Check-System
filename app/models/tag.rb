class Tag < ActiveRecord::Base
  belongs_to :location
  belongs_to :part
end

# == Schema Information
#
# Table name: tags
#
#  id         :integer         not null, primary key
#  count_1    :integer
#  count_2    :integer
#  count_3    :integer
#  created_at :datetime
#  updated_at :datetime
#

