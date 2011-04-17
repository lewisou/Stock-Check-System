require 'ext/all_order'

class Check < ActiveRecord::Base
  scope :curr_s, where(:current.eq => true).limit(1)
  has_many :item_groups
  has_many :items, :through => :item_groups
  has_many :locations
  belongs_to :admin
  belongs_to :location_xls, :class_name => "::Attachment"

  attr_accessor :item_groups_xls, :items_xls, :locations_xls, :inventories_xls
  validates_presence_of :item_groups_xls, :items_xls, :locations_xls, :inventories_xls, :on => :create

  before_create :refresh_location, :refresh_item_and_group
  def refresh_item_and_group
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

      Item.create(:description => row[1],
      :item_group => (self.item_groups.select {|g| g.name == row[6]}).first,
      :cost => row[20],
      :max_quantity => row[72],
      :code => row[74],
      :al_id => row[75]
      )
    end
  end

  def refresh_location
    self.locations = []
    @book = Spreadsheet.open @locations_xls.path
    @sheet0 = @book.worksheet 0
    
    @sheet0.each_with_index do |row, index|
      next if (index == 0 || row[0].blank?)

      self.locations << Location.create(:code => row[0], 
                      :description => row[1],
                      :is_active => (row[7].downcase == 'yes'),
                      :is_available => (row[8]),
                      :from_al => true)
    end
  end

  after_create :refresh_inventories
  def refresh_inventories
    @book = Spreadsheet.open @inventories_xls.path
    @sheet0 = @book.worksheet 0
    
    @sheet0.each_with_index do |row, index|
      next if (index == 0 || row[0].blank?)

      
      self.locations.find_by_code(row[1])
      Inventory.create(
        :item => self.items.find_by_code(row[0]),
        :location => self.locations.find_by_code(row[1]),
        :quantity => row[7],
        :from_al => true
      ).create_default_tag!
    end
  end

  before_create :init_properties
  def init_properties
    Check.curr_s.each {|c| c.current = false; c.save}
    self.current = true

    self.state = 'open'
  end
  
  def make_current!
    Check.curr_s.each {|c| c.current = false; c.save}
    self.current = true
    
    return self.save
  end

  def generate_xls
    self.location_xls = ::Attachment.new(:data => ALL_ORDER::Import.locations(self))
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
#

