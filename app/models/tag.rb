class Tag < ActiveRecord::Base
  scope :in_check, lambda {|check_id| includes(:inventory => {:location => :check}).where(:checks => {:id => check_id}) }
  scope :not_finish, lambda{|count| where("count_#{count}".to_sym.eq % nil | "count_#{count}".to_sym.eq % 0)}
  scope :finish, lambda{|count| where("count_#{count}".to_sym.gt % 0)}

  belongs_to :inventory

  search_methods :counted_by
  scope :counted_by, lambda { |counter_count|
    counter = Counter.find(counter_count.split('_').first)
    count = counter_count.split('_').last.to_i
    
    includes(:inventory => :location).where(:locations => {:id => counter.assigns.where(:count => count).map(&:location).map(&:id)})
  }

  search_methods :tolerance_q
  scope :tolerance_q, lambda { |quantity|
    {:conditions => ["abs((tags.count_1 - tags.count_2) / cast(tags.count_1 as float)) * 100 >= ? and tags.count_1 > 0", quantity.to_f.abs]}
  }

  search_methods :tolerance_v
  scope :tolerance_v, lambda{|value| includes(:inventory => :item).where(["abs(tags.count_1 * items.cost - tags.count_2 * items.cost) >= ?", value.to_f.abs])}


  attr_accessor :location_id, :item_id
  before_save :adj_inventory
  def adj_inventory
    if @location_id && @item_id
      chk = Location.find(@location_id).check

      return if Item.find(@item_id).item_group.check != chk

      inv = Inventory.in_check(chk.id).where(:location_id.eq % @location_id & :item_id.eq % @item_id).first
      if inv
        self.inventory = inv
      else
        self.inventory = Inventory.create(
          :item => Item.find(@item_id),
          :location => Location.find(@location_id)
        )
      end
    end
  end

  def final_count
    if self.count_1.nil? || self.count_2.nil?
      return nil
    end
    
    if self.count_1 == self.count_2
      return self.count_1
    end

    self.count_3.nil? ? [self.count_1, self.count_2].min : self.count_3
  end
  
  def counted_value
    return nil if final_count.nil? || self.inventory.item.try(:cost).nil?
    final_count * self.inventory.item.try(:cost)
  end

end





# == Schema Information
#
# Table name: tags
#
#  id           :integer         not null, primary key
#  count_1      :integer
#  count_2      :integer
#  count_3      :integer
#  created_at   :datetime
#  updated_at   :datetime
#  inventory_id :integer
#  sloc         :string(255)
#

