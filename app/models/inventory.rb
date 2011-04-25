class Inventory < ActiveRecord::Base
  scope :in_check, lambda {|check_id| includes(:location => :check).where(:checks => {:id => check_id}) }
  scope :need_adjustment, where("quantity <> cached_counted")

  belongs_to :item
  belongs_to :location
  has_many :tags

  def self.cache_counted check
    in_check(check.id).all.each {|inv| inv.cached_counted = inv.counted; inv.save(:validate => false)}
  end

  def create_default_tag!
    self.tags.create
  end
  
  def counted
    self.tags.map(&:final_count).sum
  end
  
  def frozen_value
    (self.quantity || 0) * (self.item.al_cost || 0)
  end
  
  def counted_value
    self.counted * (self.item.cost || 0)
  end
  
  def item_full_name
    self.item.nil? ? "" : self.item.try(:code)
  end
  
  def adj_count
    self.cached_counted - self.quantity
  end
  
  def adj_item_cost
    self.adj_count > 0 ? self.item.cost : ""
  end
end



# == Schema Information
#
# Table name: inventories
#
#  id             :integer         not null, primary key
#  item_id        :integer
#  location_id    :integer
#  quantity       :integer
#  created_at     :datetime
#  updated_at     :datetime
#  from_al        :boolean         default(FALSE)
#  cached_counted :integer
#

