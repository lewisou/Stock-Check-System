class Inventory < ActiveRecord::Base
  scope :in_check, lambda {|check_id| includes(:item => {:item_group => :check}).where(:checks => {:id => check_id}) }

  belongs_to :item
  belongs_to :location
  has_many :tags

  def create_default_tag!
    self.tags.create
  end
end


# == Schema Information
#
# Table name: inventories
#
#  id          :integer         not null, primary key
#  item_id     :integer
#  location_id :integer
#  quantity    :integer
#  created_at  :datetime
#  updated_at  :datetime
#  from_al     :boolean         default(FALSE)
#

