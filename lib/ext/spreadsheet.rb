require 'spreadsheet'
  
module Spreadsheet
  class Workbook
    def render_tags tags, title
      sheet1 = self.create_worksheet :name => (title || "tags")
      
      title_format = Spreadsheet::Format.new :pattern_fg_color => :builtin_black, :color => :yellow, :pattern => 1, :weight => :bold
      sheet1.row(0).default_format = title_format
      
      sheet1.row(0).concat %w{Tag Location Item Description}
      
      tags.each_with_index do |tag, index|
        sheet1.row(index + 1).concat [tag.id, tag.inventory.location.code, tag.inventory.item.code, tag.inventory.item.description]
      end
      
      data = StringIO.new
      self.write(data)
      data.string
    end
    
    def render_inventories inventories, title
      sheet1 = self.create_worksheet :name => (title || "Inventory")
      
      title_format = Spreadsheet::Format.new :pattern_fg_color => :builtin_black, :color => :yellow, :pattern => 1, :weight => :bold
      sheet1.row(0).default_format = title_format
      
      sheet1.row(0).concat %w{Location Item Description Cost FrozenQTY Counted FrozenValue CountedValue}
      
      inventories.each_with_index do |inventory, index|
        sheet1.row(index + 1).concat [inventory.location.code, inventory.item.code, inventory.item.description,
          inventory.item.cost, inventory.quantity, inventory.counted, inventory.frozen_value, inventory.counted_value
          ]
      end
      
      data = StringIO.new
      self.write(data)
      data.string
    end

  end
end
