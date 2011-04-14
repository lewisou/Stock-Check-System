class ItemsController < ApplicationController
  layout "tags"
  before_filter { @sub_menu = :add }

  def show
    @item = Item.find(params[:id])
  end

  def index
    @search = Item.search(params[:search])
    @items = @search.paginate(:page => params[:page])
  end

  def input_price
    @item = Item.find(params[:id])
  end

  def update_price
    @item = Item.find(params[:id])

    if @item.update_attributes(params[:part])
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
