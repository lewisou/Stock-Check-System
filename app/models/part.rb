class Part < ActiveRecord::Base
  has_many :tags
end


# == Schema Information
#
# Table name: parts
#
#  id          :integer         not null, primary key
#  code        :string(255)
#  description :text
#  cost        :float
#  created_at  :datetime
#  updated_at  :datetime
#  qb_id       :integer
#

