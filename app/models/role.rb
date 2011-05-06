class Role < ActiveRecord::Base
  has_and_belongs_to_many :admins

end

# == Schema Information
#
# Table name: roles
#
#  id         :integer         not null, primary key
#  code       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

