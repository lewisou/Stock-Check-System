require 'ext/spreadsheet'

class LocationsController < BaseController
  layout "settings"
  
  before_filter { @sub_menu = :location }

  def index
    @search = curr_check.locations.search(params[:search])
    
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
