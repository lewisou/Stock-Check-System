ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'ext/ruby-ole'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  # fixtures :all

  # Add more helper methods to be used by all tests here...
  
  def new_check
    Check.new(
      :description => Time.now.to_i,
      :inventories_xls => File.new("#{Rails.root.to_s}/test/files/inventories.xls"),
      :locations_xls => File.new("#{Rails.root.to_s}/test/files/locations.xls"),
      :item_groups_xls => File.new("#{Rails.root.to_s}/test/files/groups.xls"),
      :items_xls => File.new("#{Rails.root.to_s}/test/files/items.xls")
    )
  end
  
  def new_blank_check
    c = Check.new(:description => "new_blank_check#{Time.now.to_i}"); 
    c.save(:validate => false);
    c
  end
end
