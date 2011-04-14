class InventoriesController < ApplicationController
  layout 'tags'
  
  def index
    @search = Inventory.in_check(curr_check.id).search(params[:search])
    @inventories = @search.paginate(:page => params[:page])
  end
end
