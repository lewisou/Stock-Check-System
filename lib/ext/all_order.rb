require 'spreadsheet'
# require 'tempfile'

module ALL_ORDER
  class Import
    def inventory_adjustment check
      
    end
    
    def self.locations check
      self.xls('Location.xls', check.locations.where(:from_al.eq => false), [:code, :is_active, :is_available, "", :description])
    end

    private
    def self.xls xls, list=[], symbols=[]
      book = Spreadsheet.open "#{Rails.root.to_s}/al_xls/#{xls}"
      sheet1 = book.worksheet 0
      
      list.each_with_index do |content, index|
        cells = symbols.collect do |s| 
          case s
          when Symbol
            content.send(s)
          when String
            s
          else
            s.to_s
         end
        end
        
        sheet1.row(index + 1).concat cells
      end
      # sheet1.row(0).concat %w{Location Item Description Cost FrozenQTY Counted FrozenValue CountedValue}
      
      rs = Tempfile.new(xls)
      book.write(rs)
      rs
    end
  end
end