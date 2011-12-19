require 'ext/all_order'
require 'ext/spreadsheet'

class Check < ActiveRecord::Base
  scope :curr_s, where(:current.eq => true).limit(1)
  scope :opt_s, where(:state => ["open", "complete", "cancel"]).curr_s
  scope :history, where(:state => "archive").order("created_at DESC")

  validates_uniqueness_of :description

  has_many :item_groups
  has_many :items, :through => :item_groups
  has_many :locations
  has_many :inventories
  has_many :assigns, :through => :locations
  has_many :activities
  has_and_belongs_to_many :generated_pdfs, :class_name => "::Attachment", :join_table => 'check_generated_pdf_attachments'
  belongs_to :admin

  belongs_to :inv_adj_xls, :class_name => "::Attachment"
  belongs_to :manual_adj_xls, :class_name => "::Attachment"

  belongs_to :instruction, :class_name => "::Attachment"
  belongs_to :instruction2, :class_name => "::Attachment"
  belongs_to :instruction3, :class_name => "::Attachment"
  belongs_to :instruction4, :class_name => "::Attachment"


  belongs_to :import_item_groups_xls, :class_name => "::Attachment"
  belongs_to :import_items_xls, :class_name => "::Attachment"
  belongs_to :import_locations_xls, :class_name => "::Attachment"
  belongs_to :import_inventories_xls, :class_name => "::Attachment"
  attr_accessor :item_groups_xls, :items_xls, :locations_xls, :inventories_xls
  validates_presence_of :item_groups_xls, :items_xls, :locations_xls, :inventories_xls, :on => :create

  before_create :save_files
  def save_files
    self.import_item_groups_xls = ::Attachment.create(:data => @item_groups_xls) unless @item_groups_xls.blank?
    self.import_items_xls = ::Attachment.create(:data => @items_xls) unless @items_xls.blank?
    self.import_locations_xls = ::Attachment.create(:data => @locations_xls) unless @locations_xls.blank?
    self.import_inventories_xls = ::Attachment.create(:data => @inventories_xls) unless @inventories_xls.blank?
  end

  attr_accessor :reimport_inv_xls, :reimport_cost_xls, :re_export_qtys_xls, :instruction_file, :instruction2_file, :instruction3_file, :instruction4_file

  validate :file_format
  def file_format
    if !@item_groups_xls.blank? && !first_row_eq(@item_groups_xls, ['Name', 'ItemType', 'ItemTypeShort', 'ExpenseAcct', 'AssetAcct', 'COGSAcct', 'IncomeAcct', 'PrimaryUOM', 'PurchaseUOM', 'PurchaseFactor', 'SaleUOM', 'SaleFactor', 'UseUOM', 'UseFactor', 'IsPurchased', 'IsSold', 'IsUsed', 'IsActive'])
      errors.add(:item_groups_xls, "Invalid format")
    end
    if !@locations_xls.blank? && !first_row_eq(@locations_xls, ['Location', 'Address 1', 'Address 2', 'Address 3', 'City', 'State', 'Zip', 'Active', 'Available'])
      errors.add(:locations_xls, "Invalid format")
    end
    if !@items_xls.blank? && !first_row_eq(@items_xls, ['Item', 'SalesDesc', 'PurchaseDesc', 'ItemType', 'ItemTypeShort', 'QBType', 'MakeUseTypeName', 'MakeUseTypeShort', 'PrimaryUOM', 'PurchUOM', 'PurchaseFactor', 'SalesUOM', 'SaleFactor', 'UseUOM', 'UseFactor', 'QuantityOnHand', 'ReorderPoint', 'ReorderAmount', 'PurchaseCost', 'LastPurchaseCost', 'AverageCost', 'Price', 'BinName', 'LocLocation', 'COGSAccount', 'SalesAccount', 'AssetAccount', 'ExpenseAccount', 'SalesTaxCode', 'PriceLevelName', 'Weight', 'Manufacturer', 'MftgPartNumber', 'UPC', 'IsActive', 'VendorPartNo', 'HasLotSer', 'Proxy', 'ImageFile', 'ItemCust1', 'ItemCust2', 'ItemCust3', 'ItemCust4', 'ItemCust5', 'ItemCust6', 'ItemCust7', 'ItemCust8', 'ItemCust9', 'ItemCust10', 'ItemCust11', 'ItemCust12', 'ItemCust13', 'ItemCust14', 'ItemCust15', 'ItemCust16', 'ItemCust17', 'ItemCust18', 'ItemCust19', 'ItemCust20', 'ItemCust21', 'ItemCust22', 'ItemCust23', 'ItemCust24', 'ItemCust25', 'ItemCust26', 'ItemCust27', 'ItemCust28', 'ItemCust29', 'ItemCust30', 'TimeCreated', 'TimeModified', 'Vendor', 'MaxQty', 'Volume', 'FullItemName', 'ID'])
      errors.add(:items_xls, "Invalid format")
    end
    if !@inventories_xls.blank? && !first_row_eq(@inventories_xls, ['Item', 'Location', 'UOM', 'PurchaseDesc', 'SalesDesc', 'AverageCost', 'IsActive', 'Qty', 'Committed', 'Allocated', 'InTransit', 'RMA', 'WIP', 'AvailableToSell', 'AvailableToShip', 'OnHand', 'Owned', 'Value', 'ItemCust1', 'ItemCust2', 'ItemCust3', 'ItemCust4', 'ItemCust5', 'ItemCust6', 'ItemCust7', 'ItemCust8', 'ItemCust9', 'ItemCust10', 'ItemCust11', 'ItemCust12', 'ItemCust13', 'ItemCust14', 'ItemCust15', 'AvailablePurchaseValue', 'PurchaseCost', 'OnHandPurchaseValue'])
      errors.add(:inventories_xls, "Invalid format")
    end
    if !@reimport_inv_xls.blank? && !first_row_eq(@reimport_inv_xls, ['Item', 'Location', 'UOM', 'PurchaseDesc', 'SalesDesc', 'AverageCost', 'IsActive', 'Qty', 'Committed', 'Allocated', 'InTransit', 'RMA', 'WIP', 'AvailableToSell', 'AvailableToShip', 'OnHand', 'Owned', 'Value', 'ItemCust1', 'ItemCust2', 'ItemCust3', 'ItemCust4', 'ItemCust5', 'ItemCust6', 'ItemCust7', 'ItemCust8', 'ItemCust9', 'ItemCust10', 'ItemCust11', 'ItemCust12', 'ItemCust13', 'ItemCust14', 'ItemCust15', 'AvailablePurchaseValue', 'PurchaseCost', 'OnHandPurchaseValue'])
      errors.add(:reimport_inv_xls, "Invalid format")
    end

    if !@reimport_cost_xls.blank? && !first_row_eq(@reimport_cost_xls, ['Item', 'SalesDesc', 'PurchaseDesc', 'ItemType', 'ItemTypeShort', 'QBType', 'MakeUseTypeName', 'MakeUseTypeShort', 'PrimaryUOM', 'PurchUOM', 'PurchaseFactor', 'SalesUOM', 'SaleFactor', 'UseUOM', 'UseFactor', 'QuantityOnHand', 'ReorderPoint', 'ReorderAmount', 'PurchaseCost', 'LastPurchaseCost', 'AverageCost', 'Price', 'BinName', 'LocLocation', 'COGSAccount', 'SalesAccount', 'AssetAccount', 'ExpenseAccount', 'SalesTaxCode', 'PriceLevelName', 'Weight', 'Manufacturer', 'MftgPartNumber', 'UPC', 'IsActive', 'VendorPartNo', 'HasLotSer', 'Proxy', 'ImageFile', 'ItemCust1', 'ItemCust2', 'ItemCust3', 'ItemCust4', 'ItemCust5', 'ItemCust6', 'ItemCust7', 'ItemCust8', 'ItemCust9', 'ItemCust10', 'ItemCust11', 'ItemCust12', 'ItemCust13', 'ItemCust14', 'ItemCust15', 'ItemCust16', 'ItemCust17', 'ItemCust18', 'ItemCust19', 'ItemCust20', 'ItemCust21', 'ItemCust22', 'ItemCust23', 'ItemCust24', 'ItemCust25', 'ItemCust26', 'ItemCust27', 'ItemCust28', 'ItemCust29', 'ItemCust30', 'TimeCreated', 'TimeModified', 'Vendor', 'MaxQty', 'Volume', 'FullItemName', 'ID'])
      errors.add(:reimport_cost_xls, "Invalid format")
    end
  end

  # before_create :refresh_location, :refresh_item_and_group
  before_create :init_colors
  # after_create :refresh_inventories

  before_update :adj_instruction, :reimport_cost
  after_update :refresh_re_export_qtys

  def refresh_all
    self.refresh_location && self.refresh_item_and_group && self.refresh_inventories
    self.reload
  end

  def set_onsite_locations ids=[]
    self.locations.each do |loc|
      loc.update_attributes(:is_remote => true)
    end

    self.locations.find(ids || []).each do |location|
      location.update_attributes(:is_remote => false)
    end
  end

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
    %w{Warehouse Desc1 Desc2 Desc3 LocationIsActive Part# Desc. ItemInAO WarehouseInAO Cost MaxQty TotalScsQty IsActive HasLotSer. ShelfLoc. FrozenQty SCS_Result_Qty AdjustQty Cost Reason},
    [[:location, :code],
      [:location, :desc1],
      [:location, :desc2],
      [:location, :desc3],
      [:location, :is_active],
      [:item, :code],
      [:item, :description],
      [:item, :from_al],
      [:location, :from_al],
      [:item, :cost],
      [:item, :max_quantity],
      [:item, :item_info, :res_qty],
      [:item, :is_active],
      [:item, :is_lotted],
      [:item, :inittags],
      :quantity,
      :result_qty,
      :ao_adj,
      :adj_item_cost,
      :manual_reason]
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
    return self.state == 'open' && Inventory.in_check(self.id).remote_s.where(:inputed_qty.eq => nil).count == 0 && Tag.in_check(self.id).countable.not_finish(2).count == 0 && Tag.in_check(self.id).countable.not_finish(1).count == 0
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

  def refresh_location
    return if self.import_locations_xls.blank?

    self.locations = []
    @book = Spreadsheet.open self.import_locations_xls.data.path
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

  def refresh_item_and_group
    return if self.import_item_groups_xls.nil?

    self.item_groups = []
    @book = Spreadsheet.open self.import_item_groups_xls.data.path
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

    @book = Spreadsheet.open self.import_items_xls.data.path
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

  def refresh_inventories
    refresh_qtys_from_xls self.import_inventories_xls.data
  end

  private unless 'test' == Rails.env
  def refresh_re_export_qtys
    refresh_qtys_from_xls @re_export_qtys_xls, :re_export_qty, :from_al => :keep
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

  def init_colors
    self.color_1, self.color_2, self.color_3 = 'B4E2D4', 'F3C4C8', 'EADFD2'
  end

  def adj_instruction
    self.instruction = ::Attachment.create(:data => @instruction_file) unless @instruction_file.nil?
    self.instruction2 = ::Attachment.create(:data => @instruction2_file) unless @instruction2_file.nil?
    self.instruction3 = ::Attachment.create(:data => @instruction3_file) unless @instruction3_file.nil?
    self.instruction4 = ::Attachment.create(:data => @instruction4_file) unless @instruction4_file.nil?
  end

  def create_update_from_row row, options={}
    return if (item = self.items.find_by_code(row[0])).blank? || (location = self.locations.find_by_code(row[1])).blank?

    inv = Inventory.in_check(self.id).where(:item_id => item.id, :location_id => location.id).first

    qty_sym = options[:quantity_sym].blank? ? :quantity : options[:quantity_sym]

    al_map = options[:from_al] == :keep ? {} : {:from_al => true}

    if inv
      inv.update_attributes(({qty_sym => (row[15].try(:to_i) || 0)}).merge(al_map))
    else
      inv = Inventory.create(
        ({:item => item,
        :location => location,
        qty_sym => row[15]}).merge(al_map)
      )
    end
    inv
  end

  def first_row_eq file, arry
    @book = Spreadsheet.open file.path
    @sheet0 = @book.worksheet 0
    @sheet0.row(0) == arry
  rescue
    false
  end

  def reimport_cost
    return if @reimport_cost_xls.blank?

    # self.items.each do |item|
    #   item.update_attributes(:cost => 0)
    # end

    @book = Spreadsheet.open @reimport_cost_xls.path
    @sheet0 = @book.worksheet 0
    @sheet0.each_with_index do |row, index|
      next if (index == 0 || row[0].blank?)

      item = self.items.find_by_code(row[74])
      next if item.nil?

      item.update_attributes(:cost => row[18])
    end
  end

end



















# == Schema Information
#
# Table name: checks
#
#  id                        :integer         not null, primary key
#  state                     :string(255)     default("init")
#  created_at                :datetime
#  updated_at                :datetime
#  current                   :boolean         default(FALSE)
#  description               :text
#  admin_id                  :integer
#  location_xls_id           :integer
#  inv_adj_xls_id            :integer
#  item_xls_id               :integer
#  color_1                   :string(255)
#  color_2                   :string(255)
#  color_3                   :string(255)
#  generated                 :boolean         default(FALSE)
#  import_time               :integer         default(1)
#  instruction_id            :integer
#  start_time                :date
#  end_time                  :date
#  credit_v                  :float
#  credit_q                  :float
#  al_account                :text
#  manual_adj_xls_id         :integer
#  final_inv                 :boolean         default(FALSE)
#  ao_adjust_acc             :text            default("INVENTORY:INVENTORY ADJUSTMENTS")
#  import_item_groups_xls_id :integer
#  import_items_xls_id       :integer
#  import_locations_xls_id   :integer
#  import_inventories_xls_id :integer
#

