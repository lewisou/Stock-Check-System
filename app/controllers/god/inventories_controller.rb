require 'ext/spreadsheet'

class God::InventoriesController < God::BaseController

  before_filter do
    @check = Check.find(params[:check_id])
    @nav = @check.current ? :control : :archive
  end

  def index
    @search = Inventory.in_check(@check.id).report_valid.search(params[:search])

    respond_to do |format|
      format.html { @inventories = @search.paginate(:page => params[:page]) }
      format.xls {
        @inventories = @search.all
        book = Spreadsheet::Workbook.new
        
        data = book.generate_xls(
        "Final Summary by value", @inventories,        
        %w{Warehouse Part# Desc. Count_1_QTY Count_2_QTY RemoteWS_QTY Frozen_QTY Frozen_Val. Final_SCS_QTY Final_SCS_Val. Adjustment_to_QTY_frozen Adjustment_Value},
        [[:location, :code], 
          [:item, :code],
          [:item, :description],
          :counted_1_qty,
          :counted_2_qty,
          :inputed_qty,
          :quantity,
          :frozen_value,
          :result_qty,
          :result_value,
          :ao_adj,
          :ao_adj_value],
          :summary => [["Net adjustment Value", @check.ao_adj_value],
          ["Sum of up and down",  @check.ao_adj_abs_value],
          ["Total Frozen Value", @check.frozen_value],
          ["Total SCS Value (Remote & Onsite)", @check.final_value]]
        )
        
        send_data data, :filename => "Check_#{@check.description}_summary_by_value.xls", :disposition => 'attachment'
      }
    end
    
  end
  
end