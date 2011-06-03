class Dataentry::InventoriesController < Dataentry::BaseController
  before_filter do
    @nav = :remote_input
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
      redirect_to edit_dataentry_inventory_path(@inventory), :notice => "Saved."
    else
      render :edit
    end
  end
end
