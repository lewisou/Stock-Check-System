class ItemsController < ApplicationController
  layout "tags"

  def new
    @item = curr_check.items.new
  end
  
  def edit
    @item = curr_check.items.find(params[:id])
  end
  
  def update
    @item = Item.find(params[:id])

    if @item.update_attributes(params[:item])
      redirect_to items_path, :notice => "Item #{@item.code} has been updated."
    else
      render :edit
    end
  end
  
  def create
    @item = curr_check.items.build(params[:item])
    @item.from_al = false
    
    if @item.save
      redirect_to items_path, :notice => "Item #{@item.code} has been created."
    else
      render :new
    end
  end
  
  def show
    @item = curr_check.items.find(params[:id])
  end

  def index
    @search = curr_check.items.search(params[:search])
    @items = @search.paginate(:page => params[:page])
  end

  def input_price
    @item = curr_check.items.find(params[:id])
  end

  def update_price
    @item = Item.find(params[:id])
    # @item = curr_check.items.find(params[:id])

    if @item.update_attributes(params[:item])
      redirect_to(@item, :notice => 'Tag was successfully updated.')
    else
      render :action => "input_price"
    end
  end

  def missing_cost
    @search = curr_check.items.where(:cost.eq % nil | :cost.eq % 0).search(params[:search])
    @items = @search.paginate(:page => params[:page])
  end

end
