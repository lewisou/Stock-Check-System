class Inventory < ActiveRecord::Base
  scope :in_check, lambda {|check_id| includes(:location => :check).where(:checks => {:id => check_id}) }
  scope :report_valid, where({:his_max.gt => 0, :from_al => true} | {:from_al => false})

  scope :need_adjustment, includes(:item).includes(:location)\
    .where(:ao_adj.not_eq => 0)\
    .where(:items => {:is_active => true, :cost.gt => 0, :from_al => true, :is_lotted => false})\
    .where(:locations => {:from_al => true, :is_active => true})\
    .report_valid.order([{:locations => :code.asc}, {:items => :code.asc}])
    # .where(:item_infos => (:remaining.eq % nil | :remaining.gte % 0))\


  scope :need_manually_adj, includes(:item).includes(:location)\
    .where(:ao_adj.not_eq => 0)\
    .where({:items => (:is_active.eq % false | :cost.lte % 0 | :cost.eq % nil | :from_al.eq % false | :is_lotted.eq % true)}\
    | {:locations => ({:from_al => false} | {:is_active => false})})\
    .report_valid.order([{:locations => :code.asc}, {:items => :code.asc}])
    # | {:item_infos => {:remaining.lt => 0}})\

  scope :remote_s, includes(:location).where(:locations => {:is_remote => true}).report_valid
  scope :onsite_s, includes(:location).where(:locations => {:is_remote => false}).report_valid

  belongs_to :item
  belongs_to :location
  belongs_to :check
  has_many :tags
  has_many :quantities

  validates_presence_of :location

  after_save :log_qty_and_flag, :refresh_item_res_qty, :refresh_location_qtys
  before_save :adj_check, :adj_qtys

  def item_full_name
    self.item.nil? ? "" : self.item.try(:code)
  end

  def adj_count
    self.result_qty - self.quantity
  end

  def adj_item_cost
    self.adj_count > 0 ? self.item.cost : nil
  end

  def create_default_tag!
    return 0 if self.location.is_remote
    
    rs = self.tags.create if self.tags.count == 0
    rs
  end

  def create_init_tags!
    return 0 if self.location.is_remote || self.tag_inited

    cod = self.location.try(:code).try(:upcase)
    return 0 if cod.blank?

    rs = ((self.item.try(:inittags) || '').split(/[,\s]/).delete_if {|ing| ing.blank? || !ing.upcase.start_with?(cod)})

    (rs.collect {|el| el.upcase.gsub(/^#{cod}/, "")}).each do |sloc|
      self.tags.create(:sloc => sloc)
    end
    self.tag_inited = true
    self.save
    return rs.size
  end

  def remote_ticket_id
    return if self.location.nil?

    if self.location.is_remote
      "R-#{self.id}"
    else
      nil
    end
  end

  def manual_reason
    return "Item is not active." unless self.item.is_active
    return "Warehouse is not active." unless self.location.is_active
    return "Item has no cost." if self.item.cost == 0 || self.item.cost.nil?
    return "Item has lotted serials #." if self.item.is_lotted
    return ""
  end

  private unless 'test' == Rails.env
  def adj_qtys
    # onsite qty
    if !self.location.try(:is_remote)
      self.counted_1_qty = (self.tags.countable.map(&:count_1).delete_if {|t| t.nil?}).sum
      self.counted_2_qty = (self.tags.countable.map(&:count_2).delete_if {|t| t.nil?}).sum
      self.counted_qty = (self.tags.countable.map(&:final_count).delete_if {|t| t.nil?}).sum
    end

    # all warehouse qty
    self.result_qty = self.location.try(:is_remote) ? (self.inputed_qty || 0) : self.counted_qty
    self.ao_adj = (self.result_qty || 0) - (self.quantity || 0)
    self.re_export_offset = self.re_export_qty - self.result_qty if self.re_export_qty

    # all warehouse value
    self.result_value = (self.result_qty || 0) * (self.item.try(:cost) || 0)
    self.frozen_value = (self.quantity || 0) * (self.item.try(:cost) || 0)
    self.ao_adj_value = (self.ao_adj || 0) * (self.item.try(:cost) || 0)

    # onsite value differ
    if !self.location.try(:is_remote)
      self.counted_1_value = (self.counted_1_qty || 0) * (self.item.try(:cost) || 0)
      self.counted_2_value = (self.counted_2_qty || 0) * (self.item.try(:cost) || 0)
      
      self.counted_1_value_differ = self.counted_1_value - self.frozen_value
      self.counted_2_value_differ = self.counted_2_value - self.frozen_value
    end

    # all warehouse value differ
    self.result_value_differ = self.result_value - self.frozen_value

    self.his_max = [self.quantities.map(&:value).map(&:to_i).map(&:abs).max.to_i, self.quantity.to_i].max
  end

  def adj_check
    self.check = self.location.check
  end

  def log_qty_and_flag
    self.check.reload unless self.check.nil?

    return if self.check.nil? || self.check.import_time.nil?

    q = self.quantities.where(:time => self.check.import_time).first
    if q
      if q.value != self.quantity || q.from_al != self.from_al
        q.update_attributes(:time => self.check.import_time, :value => self.quantity, :from_al => self.from_al)
      end
    else
      self.quantities.create(:time => self.check.import_time, :value => self.quantity, :from_al => self.from_al)
    end
    
    self.reload
  end

  def refresh_item_res_qty
    self.item.item_info.save unless self.item.nil?
    self.reload
  end

  def refresh_location_qtys
    return if self.location.nil?

    if self.location.location_info.nil?
      self.location.create_location_info
      self.location.reload
    end

    self.location.location_info.save
  end

end














# == Schema Information
#
# Table name: inventories
#
#  id                     :integer         not null, primary key
#  item_id                :integer
#  location_id            :integer
#  quantity               :integer         default(0)
#  created_at             :datetime
#  updated_at             :datetime
#  from_al                :boolean         default(FALSE)
#  inputed_qty            :integer
#  counted_qty            :integer
#  result_qty             :integer
#  check_id               :integer
#  tag_inited             :boolean         default(FALSE)
#  counted_1_qty          :integer
#  counted_2_qty          :integer
#  counted_1_value        :float
#  counted_2_value        :float
#  result_value           :float
#  frozen_value           :float
#  ao_adj                 :integer
#  ao_adj_value           :float
#  re_export_qty          :integer
#  re_export_offset       :integer
#  his_max                :integer
#  counted_1_value_differ :float
#  counted_2_value_differ :float
#  result_value_differ    :float
#

