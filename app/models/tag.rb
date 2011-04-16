class Tag < ActiveRecord::Base
  scope :in_check, lambda {|check_id| includes(:inventory => {:item => {:item_group => :check}}).where(:checks => {:id => check_id}) }
  scope :not_finish, lambda{|count| where("count_#{count}".to_sym.eq % nil | "count_#{count}".to_sym.eq % 0)}
  scope :finish, lambda{|count| where("count_#{count}".to_sym.gt % 0)}
  

  belongs_to :inventory

  attr_accessor :location_id, :item_id

  search_methods :tolerance_q
  scope :tolerance_q, lambda { |quantity|
    {:conditions => ["(abs(tags.count_1 - tags.count_2) / tags.count_1) * 100 >= ? and tags.count_1 is not null", quantity.to_i.abs]}
  }

  search_methods :tolerance_v
  scope :tolerance_v, lambda { |value|
    {
      :joins => {:inventory => :item},
      :conditions => ["abs(tags.count_1 * items.cost - tags.count_2 * items.cost) >= ?", value.to_f.abs]
    }
  }

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

  # before_create :adjust_inventory
  # def adjust_inventory
  #   return unless @location_id
  # 
  #   chk = self.inventory.item.item_group.check # get check
  #   lca = chk.locations.find(@location_id) # get new location
  # 
  #   if(lca && lca != self.inventory.location) # new location exists && location changed
  # 
  #     # adjust location ###########
  #     inv = self.inventory.item.inventories.joins(:location).where(:locations => {:id => lca.id}).first # if inventory exists
  #     if inv
  #       self.inventory = inv
  #     elsif
  #       # if new inventory does not exists, then create
  #       self.inventory = Inventory.create(
  #         :item => self.inventory.item,
  #         :location => lca
  #       )
  #     end
  #     # end ########################
  # 
  #   end
  # 
  # end

  def final_count
    if self.count_1 == self.count_2
      return self.count_1 || 0
    end
    
    return self.count_3 || 0
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
#

