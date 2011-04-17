class Inventory < ActiveRecord::Base
  scope :in_check, lambda {|check_id| includes(:item => {:item_group => :check}).where(:checks => {:id => check_id}) }

  belongs_to :item
  belongs_to :location
  has_many :tags

  def create_default_tag!
    self.tags.create
  end
  
  def counted
    self.tags.map(&:final_count).sum
  end
  
  def frozen_value
    (self.quantity || 0) * (self.item.cost || 0)
  end
  
  def counted_value
    self.counted * (self.item.cost || 0)
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

