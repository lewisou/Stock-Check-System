class Tag < ActiveRecord::Base
  scope :raw_in_chk, lambda { |check_id| includes(:inventory => {:location => :check}).where(:checks => {:id => check_id}) }
  scope :countable, includes(:inventory => :location).where(:locations => {:is_remote => false}).where(:state.not_eq % "deleted" | :state.eq % nil)
  scope :in_check, lambda { |check_id| raw_in_chk(check_id).countable }
  scope :not_finish, lambda{|count| where("count_#{count}".to_sym.eq % nil).countable}
  scope :finish, lambda{|count| where("count_#{count}".to_sym.not_eq % nil).countable}
  scope :deleted_s, where(:state => "deleted")
  scope :ready_to_print, where(:wait_for_print => true).countable

  belongs_to :inventory

  search_methods :counted_by
  scope :counted_by, lambda { |counter_count|
    counter = Counter.find(counter_count.split('_').first)
    count = counter_count.split('_').last.to_i
    
    includes(:inventory => :location).where(:locations => {:id => counter.assigns.where(:count => count).map(&:location).map(&:id)})
  }

  search_methods :tolerance_q
  scope :tolerance_q, lambda { |quantity|
    where("abs((tags.count_1 - tags.count_2) / least(cast(tags.count_1 as float), cast(tags.count_2 as float))) * 100 > ? and least(cast(tags.count_1 as float), cast(tags.count_2 as float)) <> 0",
    quantity.to_f.abs).countable
  }

  search_methods :tolerance_v
  scope :tolerance_v, lambda {|value| includes(:inventory => :item).where(["abs(tags.count_1 * items.cost - tags.count_2 * items.cost) > ?", value.to_f.abs]).countable}

  scope :tole_q_or_v, lambda {|quantity, value| includes(:inventory => :item) \
    .where("(least(cast(tags.count_1 as float), cast(tags.count_2 as float)) <> 0 and abs((tags.count_1 - tags.count_2) / least(cast(tags.count_1 as float), cast(tags.count_2 as float))) * 100 >= ?) or (abs(tags.count_1 * items.cost - tags.count_2 * items.cost) >= ?)", 
      (quantity || 0).to_f.abs, (value || 0).to_f.abs).countable}


  after_save :launch_inv_save
  after_destroy :launch_inv_save_with_out_reload
  def launch_inv_save
    self.inventory.try(:save)
    self.reload
  end
  
  def launch_inv_save_with_out_reload
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
    elsif self.count_1 == self.count_2 && self.count_3.nil?
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
    return 0 if self.count_2.nil? || self.count_1.nil?

    bas = [self.count_1, self.count_2].min
    return 0 if bas == 0

    return (((count_2 - count_1).to_f / bas.to_f).abs * 100).to_f.round(3).abs if bas > 0
  end

  def value_1
    ((self.count_1 || 0) * (self.inventory.item.try(:cost) || 0)).round(3)
  end
  
  def value_2
    ((self.count_2 || 0) * (self.inventory.item.try(:cost) || 0)).round(3)
  end

  def value_differ
    return nil if self.count_2.nil? || self.count_1.nil? || self.inventory.item.try(:cost).nil? || self.inventory.item.try(:cost) == 0

    return ((self.count_2 - self.count_1) * self.inventory.item.try(:cost)).round(3).abs
  end
end











# == Schema Information
#
# Table name: tags
#
#  id             :integer         not null, primary key
#  count_1        :integer
#  count_2        :integer
#  count_3        :integer
#  created_at     :datetime
#  updated_at     :datetime
#  inventory_id   :integer
#  sloc           :string(255)
#  final_count    :integer
#  state          :string(255)
#  adjustment     :integer
#  audit          :integer
#  wait_for_print :boolean         default(TRUE)
#  printed_time   :integer         default(0)
#

