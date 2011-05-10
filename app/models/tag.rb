class Tag < ActiveRecord::Base
  scope :in_check, lambda {|check_id| includes(:inventory => {:location => :check}).where(:checks => {:id => check_id}) }
  scope :not_finish, lambda{|count| where("count_#{count}".to_sym.eq % nil & (:state.not_eq % "deleted" | :state.eq % nil))}
  scope :finish, lambda{|count| where("count_#{count}".to_sym.not_eq % nil & (:state.not_eq % "deleted" | :state.eq % nil))}
  scope :deleted_s, where(:state => "deleted")
  scope :countable, where(:state.not_eq % "deleted" | :state.eq % nil)

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
  scope :tolerance_v, lambda {|value| includes(:inventory => :item).where(["abs(tags.count_1 * items.cost - tags.count_2 * items.cost) >= ?", value.to_f.abs])}

  scope :tole_q_or_v, lambda {|quantity, value| includes(:inventory => :item) \
    .where(["(abs((tags.count_1 - tags.count_2) / cast(tags.count_1 as float)) * 100 >= ? and tags.count_1 > 0) or (abs(tags.count_1 * items.cost - tags.count_2 * items.cost) >= ?)", (quantity || 0).to_f.abs, (value || 0).to_f.abs])}


  after_save :launch_inv_save
  after_destroy :launch_inv_save
  def launch_inv_save
    self.inventory.try(:save)
  end

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

  before_save :adj_final_count
  def adj_final_count
    if !self.adjustment.nil?
      self.final_count = self.adjustment
    elsif self.count_1.nil? || self.count_2.nil?
      self.final_count = nil
    elsif self.count_1 == self.count_2
      self.final_count = self.count_1
    else
      self.final_count = self.count_3.nil? ? [self.count_1, self.count_2].min : self.count_3
    end
  end
  
  def counted_value
    return nil if final_count.nil? || self.inventory.item.try(:cost).nil?
    final_count * self.inventory.item.try(:cost)
  end
  
  def count_differ
    return nil if self.count_2.nil? || self.count_1.nil?

    return (((count_2 - count_1).to_f / count_1.to_f).abs * 100).to_i.abs if count_1 > 0
  end

  def value_differ
    return nil if self.count_2.nil? || self.count_1.nil? || self.inventory.item.try(:cost).nil? || self.inventory.item.try(:cost) == 0

    return ((self.count_2 - self.count_1) * self.inventory.item.try(:cost)).abs
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
#  final_count  :integer
#  state        :string(255)
#

