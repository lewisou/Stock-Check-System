class PartsController < ApplicationController
  layout "tags"
  before_filter { @sub_menu = :add }

  def show
    @part = Part.find(params[:id])
  end

  def index
    @search = Part.search(params[:search])
    @parts = @search.paginate(:page => params[:page])
  end

  def input_price
    @part = Part.find(params[:id])
  end

  def update_price
    @part = Part.find(params[:id])

    if @part.update_attributes(params[:part])
      redirect_to(@part, :notice => 'Tag was successfully updated.')
    else
      render :action => "input_price"
    end
  end

  def missing_cost
    @search = Part.where(:code.eq % nil | :cost.eq % 0).search(params[:search])
    @parts = @search.paginate(:page => params[:page])
  end

end
