class Adm::InventoriesController < Adm::BaseController
  layout 'tags'
  
  def index
    @search = curr_check.inventories.remote_s.search(params[:search])
    @inventories = @search.paginate(:page => params[:page])
  end

  def edit
    @inventory = Inventory.find(params[:id])
  end
  
  def update
    @inventory = Inventory.find(params[:id])
    
    if @inventory.update_attributes(params[:inventory])
      redirect_to adm_inventories_path, :notice => "Inputed successfully."
    else
      render :edit
    end
  end
end
