class Dataentry::InventoriesController < Dataentry::BaseController
  before_filter do
    @nav = :remote_input
  end

  def new
    @item = Item.find(params[:item_id])
    @inventory = @item.inventories.new
  end

  def index
    @search = curr_check.inventories.remote_s.search(params[:search])

    respond_to do |format|
      format.html { @inventories = @search.paginate(:page => params[:page]) }
    end
  end

  def edit
    @inventory = curr_check.inventories.remote_s.find(params[:id])
  end

  def update
    @inventory = curr_check.inventories.remote_s.find(params[:id])

    if @inventory.update_attributes(:inputed_qty => params[:inventory][:inputed_qty])
      render :text => @inventory.inputed_qty
      # redirect_to dataentry_inventories_path, :notice => "Successfully Saved."
    else
      render :edit
    end
  end
  
  def create
    @item = Item.find(params[:item_id])
    @inventory = @item.inventories.build(params[:inventory])
    
    if @inventory.save
      redirect_to dataentry_inventories_path, :notice => "Remote Warehouse Ticket R-#{@inventory.id} created."
    else
      render :new
    end

  end
end
