class God::RechecksController < God::BaseController
  before_filter do
    @nav = :control
  end

  def edit
    @check = curr_check
  end

  def update
    @check = curr_check

    if @check.update_attributes(params[:check])
      redirect_to god_rechecks_path, :notice => "Re-check data imported."
    else
      render :edit
    end
  end

  def index
    @check = curr_check
    @search = Inventory.in_check(@check.id).search(params[:search])

    respond_to do |format|
      format.html { @inventories = @search.paginate(:page => params[:page]) }
      format.xls {
        @inventories = @search.all
        book = Spreadsheet::Workbook.new
        
        data = book.generate_xls(
        "Re-check", @inventories,        
        %w{Warehouse Part# Desc. Frozen_QTY Final_SCS_QTY Adjustment_to_QTY_frozen Re_Export_Qty Re_Export_offset},
        [[:location, :code], 
          [:item, :code],
          [:item, :description],
          :quantity,
          :result_qty,
          :ao_adj,
          :re_export_qty,
          :re_export_offset]
        )

        send_data data, :filename => "Re-check_#{@check.description}.xls", :disposition => 'attachment'
      }
    end
  end
end