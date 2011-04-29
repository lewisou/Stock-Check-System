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
    rs = self.tags.create if self.tags.count == 0
    rs
  end
  
  def counted
    self.tags.map(&:final_count).sum
  end
  
  def counted_in_1
    self.counted_in 1
  end
  
  def counted_in_2
    self.counted_in 2
  end
  
  def counted_value_in_1
    self.counted_value_in 1
  end
  
  def counted_value_in_2
    self.counted_value_in 2
  end

  def counted_value_in count
    self.counted_in(count) * (self.item.try(:cost) || 0)
  end  
  
  def counted_in count
    (self.tags.collect {|t| t.send("count_#{count}") || 0}).sum
  end
  
  def frozen_value
    (self.quantity || 0) * (self.item.try(:al_cost) || 0)
  end
  
  def counted_value
    self.counted * (self.item.try(:cost) || 0)
  end
  
  def item_full_name
    self.item.nil? ? "" : self.item.try(:code)
  end
  
  def adj_count
    self.cached_counted - self.quantity
  end
  
  def adj_item_cost
    self.adj_count > 0 ? self.item.cost : nil
  end
  
  def create_init_tags!
    cod = self.location.try(:code).try(:upcase)
    return 0 if cod.blank?
    
    rs = (self.item.try(:inittags) || '').split(/[, ]/).delete_if {|ing| ing.blank? || !ing.upcase.start_with?(cod)}
    
    (rs.collect {|el| el.upcase.delete(cod) }).each do |sloc|
      self.tags.create(:sloc => sloc)
    end
    return rs.size
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

