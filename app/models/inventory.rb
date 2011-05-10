class Inventory < ActiveRecord::Base
  scope :in_check, lambda {|check_id| includes(:location => :check).where(:checks => {:id => check_id}) }
  scope :need_adjustment, where("quantity <> result_qty")
  scope :remote_s, includes(:location).where(:locations => {:is_remote => true})


  belongs_to :item
  belongs_to :location
  belongs_to :check
  has_many :tags
  has_many :quantities

  validates_presence_of :location

  after_save :log_qty
  before_save :adj_check, :adj_qtys

  def create_default_tag!
    return 0 if self.location.is_remote
    
    rs = self.tags.create if self.tags.count == 0
    rs
  end

  # def counted
  #   self.tags.map(&:final_count).sum
  # end
  
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
    self.result_qty * (self.item.try(:cost) || 0)
  end
  
  def item_full_name
    self.item.nil? ? "" : self.item.try(:code)
  end
  
  def adj_count
    self.result_qty - self.quantity
  end
  
  def adj_item_cost
    self.adj_count > 0 ? self.item.cost : nil
  end
  
  def create_init_tags!
    return 0 if self.location.is_remote || self.tag_inited
    
    cod = self.location.try(:code).try(:upcase)
    return 0 if cod.blank?
    
    rs = (self.item.try(:inittags) || '').split(/[, ]/).delete_if {|ing| ing.blank? || !ing.upcase.start_with?(cod)}
    
    (rs.collect {|el| el.upcase.delete(cod) }).each do |sloc|
      self.tags.create(:sloc => sloc)
    end
    self.tag_inited = true
    self.save
    return rs.size
  end

  private unless 'test' == Rails.env
  def adj_qtys
    # unless self.location.try(:is_remote)
    #   self.inputed_qty = nil
    # end
    # 
    # if self.location.try(:is_remote)
    #   self.counted_qty = nil
    # else
    #   self.counted_qty = (self.tags.countable.map(&:final_count).delete_if {|t| t.nil?}).sum
    # end
    # 
    if !self.location.try(:is_remote)
      self.counted_qty = (self.tags.countable.map(&:final_count).delete_if {|t| t.nil?}).sum
    end

    self.result_qty = self.location.try(:is_remote) ? self.inputed_qty : self.counted_qty
  end

  def adj_check
    self.check = self.location.check
  end

  def log_qty
    self.check.reload unless self.check.nil?

    return if self.check.nil? || self.check.import_time.nil? || self.quantity.nil?
    
    unless self.quantities.where(:time => self.check.import_time).count > 0
      self.quantities.create(:time => self.check.import_time, :value => self.quantity)
    end
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
#  inputed_qty :integer
#  counted_qty :integer
#  result_qty  :integer
#  check_id    :integer
#  tag_inited  :boolean         default(FALSE)
#

