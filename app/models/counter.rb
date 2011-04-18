class Counter < ActiveRecord::Base
  has_many :assigns, :class_name => "::Assign"
  has_many :locations, :through => :assigns
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

