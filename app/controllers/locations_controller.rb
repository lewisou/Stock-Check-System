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
  
  
end
