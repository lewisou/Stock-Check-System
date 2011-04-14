class Counter < ActiveRecord::Base
  has_and_belongs_to_many :locations
end

# == Schema Information
#
# Table name: counters
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

