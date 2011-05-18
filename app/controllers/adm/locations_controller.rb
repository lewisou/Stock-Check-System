require 'ext/spreadsheet'

class Adm::LocationsController < Adm::BaseController
  layout "tags"
  
  before_filter { @sub_menu = :items }

  def new
    @location = Location.new
  end

  def index
    @search = curr_check.locations.tagable.search(params[:search])
    
    respond_to do |format|
      format.html {
        @locations = @search.paginate(:page => params[:page])
      }
      format.xls {
        @locations = @search.all
        send_data Spreadsheet::Workbook.new.render_location_counters(@locations), 
        :filename => "Counter_by_Location.xls", :disposition => 'attachment'
      }
    end
  end

  def show
  end

  def create
    @location = curr_check.locations.build(params[:location])
    @location.is_remote = false

    respond_to do |format|
      if @location.save
        format.html { redirect_to( adm_counters_path, :notice => 'Onsite Location was successfully created.') }
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
