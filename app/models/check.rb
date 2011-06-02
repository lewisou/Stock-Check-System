require 'ext/all_order'
require 'ext/spreadsheet'

class Check < ActiveRecord::Base
  scope :curr_s, where(:current.eq => true).limit(1)
  scope :opt_s, where(:state => ["open", "complete", "cancel"]).curr_s
  scope :history, where(:state => "archive").order("created_at DESC")

  has_many :item_groups
  has_many :items, :through => :item_groups
  has_many :locations
  has_many :inventories
  has_many :assigns, :through => :locations
  has_many :activities
  belongs_to :admin
  belongs_to :inv_adj_xls, :class_name => "::Attachment"
  belongs_to :manual_adj_xls, :class_name => "::Attachment"
  belongs_to :instruction, :class_name => "::Attachment"

  attr_accessor :item_groups_xls, :items_xls, :locations_xls, :inventories_xls, :reimport_inv_xls, :instruction_file, :re_export_qtys_xls
  validates_presence_of :item_groups_xls, :items_xls, :locations_xls, :inventories_xls, :on => :create
  validates_uniqueness_of :description

  before_create :refresh_location, :refresh_item_and_group, :init_colors
  after_create :refresh_inventories

  before_update :adj_instruction
  after_update :refresh_re_export_qtys

  def set_remotes ids=[]
    self.locations.each do |loc|
      loc.update_attributes(:is_remote => false)
    end

    self.locations.find(ids || []).each do |location|
      location.update_attributes(:is_remote => true)
    end
  end

  def make_current!
    Check.where(:id.not_eq => self.id).each {|c| c.current = false; c.save(:validate => false)}

    self.current = true
    self.save(:validate => false)
  end

  def generate_xls
    # self.location_xls = ::Attachment.new(:data => ALL_ORDER::Import.locations(self))
    # self.item_xls = ::Attachment.new(:data => ALL_ORDER::Import.items(self))
    self.inv_adj_xls = ::Attachment.new(:data => ALL_ORDER::Import.inventory_adjustment(self))

    self.manual_adj_xls = ::Attachment.new(:data => Spreadsheet::Workbook.new.generate_xls_file(
    "All Order Manual Adj", (self.inventories.need_manually_adj || []),
    %w{Warehouse Desc1 Desc2 Desc3 Part# Desc. Cost MaxQty TotalScsQty IsActive HasLotSer. ShelfLoc. SCS_Result_Qty},
    [[:location, :code],
      [:location, :desc1],
      [:location, :desc2],
      [:location, :desc3],
      [:item, :code],
      [:item, :description],
      [:item, :cost],
      [:item, :max_quantity],
      [:item, :item_info, :res_qty],
      [:item, :is_active],
      [:item, :is_lotted],
      [:item, :inittags],
      :result_qty]
    ))
  end

  def finish_count?
    Tag.in_check(self.id).countable.not_finish(1).count == 0 && Tag.in_check(self.id).countable.not_finish(2).count == 0
  end
  
  def finish_count_in count
    Tag.in_check(self.id).countable.not_finish(count).count == 0
  end

  def generate!
    return if self.generated

    self.inventories.each do |inv|
      inv.create_default_tag! if inv.create_init_tags! == 0
    end
    self.generated = true
    self.save
  end

  # repeated code for speed
  def inputed_value
    Inventory.in_check(self.id).remote_s.sum("result_value").to_f
  end

  def counted_value
    Inventory.in_check(self.id).onsite_s.sum("result_value").to_f
  end

  def count_time_value time
    Inventory.in_check(self.id).onsite_s.sum("counted_#{time}_value").to_f
  end

  def onsite_frozen_value
    Inventory.in_check(self.id).onsite_s.sum("frozen_value").to_f
  end

  def remote_frozen_value
    Inventory.in_check(self.id).remote_s.sum("frozen_value").to_f
  end

  def frozen_value
    Inventory.in_check(self.id).sum("frozen_value").to_f
  end

  def final_value
    Inventory.in_check(self.id).sum("result_value").to_f
  end

  def ao_adj_value
    Inventory.in_check(self.id).sum("ao_adj_value").to_f
  end

  def ao_adj_abs_value
    Inventory.in_check(self.id).sum("abs(ao_adj_value)").to_f
  end

  def archive!
    self.update_attributes(:state => "archive", :current => false)

    Role.where(:code.not_eq => "controller").all.each do |role|
      role.admins = []
      role.save
    end
  end
  
  def can_complete?
    return self.state == 'open' && self.final_inv && Inventory.in_check(self.id).remote_s.where(:inputed_qty.eq => nil).count == 0 && Tag.in_check(self.id).countable.not_finish(2).count == 0 && Tag.in_check(self.id).countable.not_finish(1).count == 0
  end
  
  def duration
    if !self.start_time.nil? && ((self.end_time || Time.now.to_date.to_time) > self.start_time.to_time)
      (self.end_time || Time.now.to_date.to_time) - self.start_time.to_time
    else
      0
    end
  end

  def switch_inv! time
    return if time.nil?
    time = time.to_i
    
    
    if self.save && self.update_attributes(:import_time => time)
      Inventory.in_check(self.id).each do |inv|
        log = inv.quantities.where(:time => time).first

        inv.update_attributes(
          :quantity => (log.try(:value) || 0),
          :from_al => (log.try(:from_al) || false)
        )
      end
      
      return true if @reimport_inv_xls.nil?
      
      @book = Spreadsheet.open @reimport_inv_xls.path
      @sheet0 = @book.worksheet 0
      @sheet0.each_with_index do |row, index|
        next if (index == 0 || row[0].blank?)
        create_update_from_row row
      end
      return true
    end
    
    false
  end

  private unless 'test' == Rails.env
  def refresh_re_export_qtys
    refresh_qtys_from_xls @re_export_qtys_xls, :re_export_qty, :from_al => :keep
  end

  def refresh_inventories
    refresh_qtys_from_xls @inventories_xls
  end

  def refresh_qtys_from_xls xls, sym = :quantity, options={}
    return if xls.nil?
    
    Inventory.in_check(self.id).each do |inv|
      inv.update_attributes(sym => 0)
    end

    @book = Spreadsheet.open xls.path
    @sheet0 = @book.worksheet 0

    @sheet0.each_with_index do |row, index|
      next if (index == 0 || row[0].blank?)
      create_update_from_row row, {:quantity_sym => sym}.merge(options)
    end
  end

  def refresh_item_and_group
    return if @item_groups_xls.nil?

    self.item_groups = []
    @book = Spreadsheet.open @item_groups_xls.path
    @sheet0 = @book.worksheet 0
    @sheet0.each_with_index do |row, index|
      next if (index == 0 || row[0].blank?)

      self.item_groups << ItemGroup.create(:name => row[0], 
                      :item_type => row[1], 
                      :item_type_short => row[2],
                      :is_purchased => (row[14]),
                      :is_sold => (row[15]),
                      :is_used => (row[16]),
                      :is_active => (row[17]))
    end

    @book = Spreadsheet.open @items_xls.path
    @sheet0 = @book.worksheet 0
    @sheet0.each_with_index do |row, index|
      next if (index == 0 || row[0].blank?)

      is_active = (row[34] || 0) == 0 ? false : true
      is_lotted = (row[36] || 0) == 0 ? false : true
      
      Item.create(:description => row[1],
      :item_group => (self.item_groups.select {|g| g.name == row[6]}).first,
      :cost => row[18],
      :al_cost => row[18],
      :is_active => is_active,
      :is_lotted => is_lotted,
      :inittags => row[41],
      :max_quantity => row[72],
      :code => row[74],
      :al_id => row[75],
      :from_al => true
      )
    end
  end

  def init_colors
    self.color_1 = 'B4E2D4'
    self.color_2 = 'F3C4C8'
    self.color_3 = 'EADFD2'
  end

  def adj_instruction
    return if @instruction_file.nil?
    
    self.instruction = ::Attachment.create(:data => @instruction_file)
  end

  def refresh_location
    return if @locations_xls.nil?

    self.locations = []
    @book = Spreadsheet.open @locations_xls.path
    @sheet0 = @book.worksheet 0
    
    @sheet0.each_with_index do |row, index|
      next if (index == 0 || row[0].blank?)

      self.locations << Location.create(:code => row[0], 
                      :desc1 => row[1],
                      :desc2 => row[2],
                      :desc3 => row[3],
                      :is_active => (row[7].downcase == 'yes'),
                      :is_available => (row[8]),
                      :from_al => true)
    end
  end

  def create_update_from_row row, options={}
    return if (item = self.items.find_by_code(row[0])).blank? || (location = self.locations.find_by_code(row[1])).blank?

    inv = Inventory.in_check(self.id).where(:item_id => item.id, :location_id => location.id).first

    qty_sym = options[:quantity_sym].blank? ? :quantity : options[:quantity_sym]

    al_map = options[:from_al] == :keep ? {} : {:from_al => true}

    if inv
      inv.update_attributes(({qty_sym => (row[7].try(:to_i) || 0)}).merge(al_map))
    else
      inv = Inventory.create(
        ({:item => item,
        :location => location,
        qty_sym => row[7]}).merge(al_map)
      )
    end
    inv
  end

end















# == Schema Information
#
# Table name: checks
#
#  id                :integer         not null, primary key
#  state             :string(255)     default("init")
#  created_at        :datetime
#  updated_at        :datetime
#  current           :boolean         default(FALSE)
#  description       :text
#  admin_id          :integer
#  location_xls_id   :integer
#  inv_adj_xls_id    :integer
#  item_xls_id       :integer
#  color_1           :string(255)
#  color_2           :string(255)
#  color_3           :string(255)
#  generated         :boolean         default(FALSE)
#  import_time       :integer         default(1)
#  instruction_id    :integer
#  start_time        :date
#  end_time          :date
#  credit_v          :float
#  credit_q          :float
#  al_account        :text
#  manual_adj_xls_id :integer
#  final_inv         :boolean         default(FALSE)
#

