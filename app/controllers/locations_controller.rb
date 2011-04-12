class LocationsController < ApplicationController
  layout "tags"
  
  before_filter { @sub_menu = :locations }

  def new
    @location = Location.new
  end

  def index
    @locations = Location.all
  end
  
  def show
  end
  
  def create
    @location = Location.new(params[:location])

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
end
