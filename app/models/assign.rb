class Assign < ActiveRecord::Base
  belongs_to :counter
  belongs_to :location

end

# == Schema Information
#
# Table name: assigns
#
#  id          :integer         not null, primary key
#  count       :integer
#  counter_id  :integer
#  location_id :integer
#  check_id    :integer
#  created_at  :datetime
#  updated_at  :datetime
#

