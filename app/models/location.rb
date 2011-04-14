class Location < ActiveRecord::Base
  has_and_belongs_to_many :counters
  belongs_to :check

end


# == Schema Information
#
# Table name: locations
#
#  id           :integer         not null, primary key
#  code         :string(255)
#  description  :text
#  created_at   :datetime
#  updated_at   :datetime
#  is_available :boolean
#  is_active    :boolean
#  check_id     :integer
#

