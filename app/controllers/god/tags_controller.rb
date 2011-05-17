require 'ext/spreadsheet'

class God::TagsController < God::BaseController

  before_filter do
    @check = Check.find(params[:check_id])
    @nav = @check.current ? :control : :archive
  end

  def index
    @search = Tag.in_check(@check.id).countable.search(params[:search])

    respond_to do |format|
      format.html { @tags = @search.paginate(:page => params[:page]) }
      format.xls {
        @tags = @search.all
        book = Spreadsheet::Workbook.new
        # data = book.generate_xls("Final Report", @tags, %w{Tag Location Item Description Counted Cost Value}, [:id, [:inventory, :location, :code], [:inventory, :item, :code], [:inventory, :item, :description], :final_count, [:inventory, :item, :cost], :counted_value])
        
        
        data = book.generate_xls(
        "Counts by location", @tags, 
        %w{Ticket_No Warehouse Shelf_Location Part_Number Description Count_1 Count_2 Count_3 Audit Final}, 
        [:id, 
          [:inventory, :location, :code],
          :sloc,
          [:inventory, :item, :code], 
          [:inventory, :item, :description],
          :count_1,
          :count_2,
          :count_3,
          :audit,
          :final_count
        ]
        )
        
        send_data data, :filename => "Check_#{@check.description}_counts_by_location.xls", :disposition => 'attachment'
      }
    end
    
  end
  
end