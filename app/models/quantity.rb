class Quantity < ActiveRecord::Base
  belongs_to :inventory
end


# == Schema Information
#
# Table name: quantities
#
#  id           :integer         not null, primary key
#  time         :integer
#  value        :integer
#  created_at   :datetime
#  updated_at   :datetime
#  inventory_id :integer
#

