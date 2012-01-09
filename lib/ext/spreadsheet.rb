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
      
      sheet1.row(0).concat %w{Location Item Description FrozenCost Cost FrozenQTY FinalQTY Adjustment FrozenValue FinalValue}
      
      inventories.each_with_index do |inventory, index|
        sheet1.row(index + 1).concat [inventory.location.code, inventory.item.try(:code), inventory.item.description,
          inventory.item.al_cost, inventory.item.cost, inventory.quantity, inventory.result_qty, (inventory.result_qty || 0) - (inventory.quantity || 0), inventory.frozen_value, inventory.result_value
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

    def generate_xls title, list, titles, symbols, options={}
      create_and_fill_sheet title, list, titles, symbols, options

      data = StringIO.new
      self.write(data)
      data.string
    end

    def advanced_generate_xls title, list, titles, symbols, options={}
      advanced_create_and_fill_sheet title, list, titles, symbols, options

      data = StringIO.new
      self.write(data)
      data.string
    end

    def generate_xls_file title, list, titles, symbols, options={}
      create_and_fill_sheet title, list, titles, symbols, options

      rs = Tempfile.new([(options[:file_name] || title), '.xls'])
      self.write(rs)
      rs
    end

    private
    def create_and_fill_sheet title, list, titles, symbols, options={}
      sheet1 = self.create_worksheet :name => title
      fill_sheet(sheet1, title, list, titles, symbols, 0, options)
    end
    
    def advanced_create_and_fill_sheet title, lists = [], titles = [], symbols = [], options={}
      sheet1 = self.create_worksheet :name => title

      start_line = 0
      lists.each_with_index do |list, index|
        start_line = fill_sheet(sheet1, title, list, titles[index], symbols[index], start_line, index == 0 ? options : {}) + 2
      end
    end

    def fill_sheet sheet1, title, list, titles, symbols, start_line = 0,  options = {}
      # title_format = Spreadsheet::Format.new :pattern_fg_color => :builtin_black, :color => :yellow, :pattern => 1, :weight => :bold
      title_format = Spreadsheet::Format.new :pattern_fg_color => :grey, :color => :black, :weight => :bold, :size => 12, :pattern => 1

      start_line ||= 0
      
      sheet1.row(start_line).default_format = title_format
      sheet1.row(start_line).concat [title]
      if options[:summary]
        sheet1.row(start_line + 1).default_format = title_format
        sheet1.row(start_line + 1).concat ["Summary"]

        options[:summary].each_with_index do |sum, index|
          sheet1[start_line + index + 2, 0] = sum[0]
          sheet1[start_line + index + 2, 1] = sum[1]
        end
      end

      start_row = options[:summary].nil? ? start_line + 1 : start_line + options[:summary].size + 3
      sheet1.row(start_row).default_format = title_format
      sheet1.row(start_row).concat titles

      list.each_with_index do |obj, index|
        fill_sheet_row(sheet1, start_row + index + 1, obj, symbols)
      end
      
      start_row + (list.try(:size) || 0)
    end

    def fill_sheet_row sheet, row_index, obj, symbols=[]
      rs = []
      symbols.each do |sym|
        case sym
        when Symbol
          rs << obj.send(sym)
        when Array
          tmp = obj
          sym.each do |ele| 
            tmp = tmp.send(ele) unless tmp.nil?
          end
          rs << tmp
        else
          sym.to_s
        end
      end
      sheet.row(row_index).concat rs
    end

  end
end
