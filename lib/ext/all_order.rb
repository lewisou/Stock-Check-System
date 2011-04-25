require 'spreadsheet'
# require 'tempfile'

module ALL_ORDER
  class Import
    def self.inventory_adjustment check
      check.cache_counted!

      self.xls('InvAdjustment', [
        {:list => Inventory.in_check(check.id).need_adjustment.map(&:location).uniq, :symbols => [:id, "INVENTORY:INVENTORY ADJUSTMENTS", :code]},
        {:list => Inventory.in_check(check.id).need_adjustment, :symbols => [:location_id, :item_full_name, :adj_count, nil, nil, :adj_item_cost]}
        ])
    end
    
    def self.locations check
      self.xls('Location', [{:list => check.locations.where(:from_al.eq % false || :data_changed.eq % true), :symbols => [:code, :is_active, :is_available, nil, :desc1, :desc2, :desc3]}])
    end

    def self.items check
      book = Spreadsheet::Workbook.new
      
      tmplas = {'Item' => ['ItemFullName', 'Group', 'Proxy', 'IsActive', 'Price', 'Sales Description', 'Tax Code', 'Default Location', 'Default Bin', 'Weight', 'Volume', 'Purchase Description', 'Cost', 'Default Vendor', 'Reorder Point', 'Reorder Amount', 'Max Quantity', 'Manufacturer', 'Manufacturer Part No.', 'UPC', 'Is Serialized', 'Linked File', 'Notes', 'BOM Instructions', 'CustomField1', 'CustomField2', 'CustomField3', 'CustomField4', 'CustomField5', 'CustomField6', 'CustomField7', 'CustomField8', 'CustomField9', 'CustomField10', 'CustomField11', 'CustomField12', 'CustomField13', 'CustomField14', 'CustomField15', 'CustomField16', 'CustomField17', 'CustomField18', 'CustomField19', 'CustomField20', 'CustomField21', 'CustomField22', 'CustomField23', 'CustomField24', 'CustomField25', 'CustomField26', 'CustomField27', 'CustomField28', 'CustomField29', 'CustomField30', 'Make Lead Time', 'Sales Lead Time', 'Default Class'],
      'Vendors' => ['ItemFullName', 'Vendor Name', 'Part No.', 'Cost', 'Min. Order', 'Order Inc.', 'Lead Time'],
      'Related Items' => ['ItemFullName', 'Related Item FullName', 'Description', 'Is Upsell', 'Is Replacement'],
      'Customer #s' => ['ItemFullName', 'Customer FullName', 'Part No.'],
      'BOM Steps' => ['ItemFullName', 'Step', 'Time', 'UOM'],
      'BOM Components' => ['ItemFullName', 'Step', 'Component ItemFullName', 'Description', 'Qty', 'Is Costed', 'Is One Time'],
      'Kit Components' => ['ItemFullName', 'Component Name', 'Type', 'Is Active', 'Comments'],
      'Kit Selections' => ['ItemFullName', 'Component Name', 'Selection ItemFullName', 'Qty', 'Price', 'Is Default', 'BOM Component Step', 'BOM Component ItemFullname'],
      'Kit Rules' => ['ItemFullName', 'Base Component Name', 'Base Selection ItemFullName', 'Variable Component Name', 'Variable Selection ItemFullName']}
      
      ['Item', 'Vendors', 'Related Items', 'Customer #s', 'BOM Steps', 'BOM Components', 'Kit Components', 'Kit Selections', 'Kit Rules'].each do |key|
        ws = book.create_worksheet :name => key
        ws.row(0).concat tmplas[key]
      end
      
      
      self.xls(book, [{:list => check.items.need_adjustment, :symbols => [:code, :group_name, nil, nil, nil, :description, nil, nil, nil, nil, nil, nil, :cost, nil, nil, nil, :adj_max_quantity]}], :name => "Items")
    end

    private
    def self.sheet sheet, list, symbols
      list.each_with_index do |content, index|
        cells = symbols.collect do |s| 
          case s
          when Symbol
            content.send(s)
          else
            s.to_s
         end
        end

        # sheet.row(index + 1).concat cells
        sheet.row(index + 1).concat cells
      end
    end
    
    def self.xls xls, content = [], options = {}
      case xls
      when String
        book = Spreadsheet.open "#{Rails.root.to_s}/al_xls/#{xls}.xls"
      else
        book = xls
      end
      
      content.each_with_index do |c, index|
        self.sheet book.worksheet(index), c[:list], c[:symbols]
      end

      rs = Tempfile.new([(options[:name] || xls), '.xls'])
      book.write(rs)
      rs
    end
  end
end