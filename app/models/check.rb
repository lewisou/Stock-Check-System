require 'ext/all_order'

class Check < ActiveRecord::Base
  scope :curr_s, where(:current.eq => true).limit(1)
  has_many :item_groups
  has_many :items, :through => :item_groups
  has_many :locations
  has_many :assigns, :through => :locations
  belongs_to :admin
  belongs_to :location_xls, :class_name => "::Attachment"
  belongs_to :inv_adj_xls, :class_name => "::Attachment"
  belongs_to :item_xls, :class_name => "::Attachment"

  attr_accessor :item_groups_xls, :items_xls, :locations_xls, :inventories_xls
  validates_presence_of :item_groups_xls, :items_xls, :locations_xls, :inventories_xls, :on => :create
  validates_uniqueness_of :description
  
  before_create :refresh_location, :refresh_item_and_group, :init_colors
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

      is_active = row[34].nil? ? false : (row[34] == 1 || row[34] == '1' || row[34] == true)
      Item.create(:description => row[1],
      :item_group => (self.item_groups.select {|g| g.name == row[6]}).first,
      :cost => row[20],
      :al_cost => row[20],
      :is_active => is_active,
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

  after_create :refresh_inventories
  def refresh_inventories
    return if @inventories_xls.nil?

    @book = Spreadsheet.open @inventories_xls.path
    @sheet0 = @book.worksheet 0

    @sheet0.each_with_index do |row, index|
      next if (index == 0 || row[0].blank?)

      self.locations.find_by_code(row[1])
      inv = Inventory.create(
        :item => self.items.find_by_code(row[0]),
        :location => self.locations.find_by_code(row[1]),
        :quantity => row[7],
        :from_al => true
      )
      inv.create_default_tag! if inv.create_init_tags! == 0
    end
  end

  before_create :init_properties
  def init_properties
    self.state = 'open'
  end

  def make_current!
    Check.where(:id.not_eq => self.id).each {|c| c.current = false; c.save(:validate => false)}

    self.current = true
    self.save(:validate => false)
  end

  def generate_xls
    self.location_xls = ::Attachment.new(:data => ALL_ORDER::Import.locations(self))
    self.item_xls = ::Attachment.new(:data => ALL_ORDER::Import.items(self))
    self.inv_adj_xls = ::Attachment.new(:data => ALL_ORDER::Import.inventory_adjustment(self))
  end
  
  def cache_counted!
    Inventory.cache_counted self
  end

  def finish_count?
    Tag.in_check(self.id).not_finish(1).count == 0 && Tag.in_check(self.id).not_finish(2).count == 0
  end
  
  def finish_count_in count
    Tag.in_check(self.id).not_finish(count).count == 0
  end

  def total_count_value count
    (Inventory.in_check(self.id).collect {|inv| inv.counted_value_in(count)}).sum
  end
  
  def total_count_final_value
    (Inventory.in_check(self.id).collect {|inv| inv.counted_value}).sum
  end
  
  def total_frozen_value
    (Inventory.in_check(self.id).map(&:quantity).delete_if {|q| q.blank?}).sum
  end
end








# == Schema Information
#
# Table name: checks
#
#  id              :integer         not null, primary key
#  state           :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  current         :boolean         default(FALSE)
#  description     :text
#  admin_id        :integer
#  location_xls_id :integer
#  inv_adj_xls_id  :integer
#  item_xls_id     :integer
#  color_1         :string(255)
#  color_2         :string(255)
#  color_3         :string(255)
#

