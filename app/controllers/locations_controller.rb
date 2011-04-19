class LocationsController < ApplicationController
  layout "tags"
  
  before_filter { @sub_menu = :locations }

  def new
    @location = Location.new
  end

  def index
    @search = curr_check.locations.search(params[:search])
    @locations = @search.paginate(:page => params[:page])
  end

  def show
  end

  def create
    @location = curr_check.locations.build(params[:location])

    assigns = []
    Counter.all.each do |counter|
      if params[:count][counter.id.to_s].to_i > 0 && params[:count][counter.id.to_s].to_i < 3
        assigns << Assign.new(:count => params[:count][counter.id.to_s], :counter => counter)
      end
    end
    @location.new_assigns, @location.curr_check = assigns, curr_check

    respond_to do |format|
      if @location.save
        format.html { redirect_to( locations_path, :notice => 'Check was successfully created.') }
        format.xml  { render :xml => @location, :status => :created, :location => @location }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @location.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @location = Location.find(params[:id])
    @location.destroy

    respond_to do |format|
      format.html { redirect_to(locations_path, :notice => "Location has been deleted.") }
      format.xml  { head :ok }
    end
  end
  
  def edit
    @location = curr_check.locations.find(params[:id])
  end
  
  def update
    @location = Location.find(params[:id])

    assigns = []
    Counter.all.each do |counter|
      if params[:count][counter.id.to_s].to_i > 0 && params[:count][counter.id.to_s].to_i < 3
        assigns << Assign.new(:count => params[:count][counter.id.to_s], :counter => counter)
      end
    end
    @location.new_assigns, @location.curr_check = assigns, curr_check

    if @location.update_attributes(params[:location])
      redirect_to locations_path, :notice => "Location #{@location.code} has been updated."
    else
      render :edit
    end
  end
  
end
