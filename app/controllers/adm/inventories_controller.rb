class Adm::InventoriesController < Adm::BaseController
  layout 'tags'

  def show
    @inventory = curr_check.inventories.remote_s.find(params[:id])
  end

  def new
    @item = curr_check.items.find(params[:item_id])
    @inventory = @item.inventories.new
  end

  def create
    @item = curr_check.items.find(params[:item_id])
    @inventory = @item.inventories.build(params[:inventory])
    
    if @inventory.save
      redirect_to adm_inventories_path, :notice => "Remote Ticket R-#{@inventory.id} Created."
    else
      render :new
    end
  end

  def index
    @search = curr_check.inventories.remote_s.search(params[:search])

    respond_to do |format|
      format.html { @inventories = @search.paginate(:page => params[:page]) }
      format.xls {
        @inventories = @search.all
        book = Spreadsheet::Workbook.new

        data = book.generate_xls(
        "Remote Warehouse Tickets", @inventories,
        %w{Ticket# Warehouse Item# Desc. FrozenQty ScsQty},
        [:remote_ticket_id,
          [:location, :code],
          [:item, :code],
          [:item, :description],
          :quantity,
          :inputed_qty]
        )
        
        send_data data, :filename => "Remote Warehouse Tickets.xls", :disposition => 'attachment'
      }
    end
  end

  def edit
    @inventory = Inventory.find(params[:id])
  end

  def update
    @inventory = Inventory.find(params[:id])
    
    if @inventory.update_attributes(params[:inventory])
      if request.xhr?
        render :partial => 'inputed_qty', :locals => {:inventory => @inventory}
      else
        redirect_to adm_inventories_path, :notice => "Inputed successfully."
      end
    else
      render :edit
    end
  end
end
