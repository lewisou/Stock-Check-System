require 'spreadsheet'
  
module Spreadsheet
  class Workbook
    
    def render_missing_tags tags
      generate_xls "Missing Tags", tags, %w{Tag Item Location}, [:id, [:inventory, :item, :code], [:inventory, :location, :code]]
    end
    
    def render_missing_cost items
      generate_xls "Missing Cost", items, %w{ItemNumber Description Cost}, [:code, :description]
    end
    
    def render_tags tags, title
      generate_xls (title || "tags"), tags, %w{Tag Location Item Description}, [:id, [:inventory, :location, :code], [:inventory, :item, :code], [:inventory, :item, :description]]
    end
    
    def render_final_report tags
      generate_xls("Final Report", tags, %w{Tag Location Item Description Counted Cost Value}, [:id, [:inventory, :location, :code], [:inventory, :item, :code], [:inventory, :item, :description], :final_count, [:inventory, :item, :cost], :counted_value])
    end
    
    def render_inventories inventories, title
      sheet1 = self.create_worksheet :name => (title || "Inventory")
      
      title_format = Spreadsheet::Format.new :pattern_fg_color => :builtin_black, :color => :yellow, :pattern => 1, :weight => :bold
      sheet1.row(0).default_format = title_format
      
      sheet1.row(0).concat %w{Location Item Description Cost FrozenQTY Counted FrozenValue CountedValue}
      
      inventories.each_with_index do |inventory, index|
        sheet1.row(index + 1).concat [inventory.location.code, inventory.item.try(:code), inventory.item.description,
          inventory.item.cost, inventory.quantity, inventory.counted, inventory.frozen_value, inventory.counted_value
          ]
      end
      
      data = StringIO.new
      self.write(data)
      data.string
    end

    def render_location_counters locations
      sheet1 = self.create_worksheet :name => ("Counter by Location")

      title_format = Spreadsheet::Format.new :pattern_fg_color => :builtin_black, :color => :yellow, :pattern => 1, :weight => :bold
      sheet1.row(0).default_format = title_format

      sheet1.row(0).concat %w{Location Count_1 Count_2}

      locations.each_with_index do |location, index|
        sheet1.row(index + 1).concat [
          location.code,
          location.assigns.where(:count => 1).map(&:counter).map(&:name).join(", "),
          location.assigns.where(:count => 2).map(&:counter).map(&:name).join(", ")          
          ]
      end
      
      data = StringIO.new
      self.write(data)
      data.string
    end

    def generate_xls title, list, titles, symbols
      sheet1 = self.create_worksheet :name => title

      title_format = Spreadsheet::Format.new :pattern_fg_color => :builtin_black, :color => :yellow, :pattern => 1, :weight => :bold
      sheet1.row(0).default_format = title_format

      sheet1.row(0).concat titles

      list.each_with_index do |obj, index|
        rs = []
        symbols.each do |sym|
          case sym
          when Symbol
            rs << obj.send(sym)
          when Array
            tmp = obj
            sym.each do |ele| 
              # if tmp.nil?
              #   tmp = ""
              #   return
              # else
                tmp = tmp.send(ele) unless tmp.nil?
              # end
            end
            rs << tmp
          else
            sym.to_s
          end
        end
        
        sheet1.row(index + 1).concat rs
      end
      
      data = StringIO.new
      self.write(data)
      data.string
    
    end

  end
end