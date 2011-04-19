class Assign < ActiveRecord::Base
  scope :in_check, lambda {|check_id| includes(:location => :check).where(:checks => {:id => check_id}) }
  
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
#  created_at  :datetime
#  updated_at  :datetime
#

