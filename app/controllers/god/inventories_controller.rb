require 'ext/spreadsheet'

class God::InventoriesController < God::BaseController

  before_filter do
    @check = Check.find(params[:check_id])
    @nav = @check.current ? :control : :archive
  end

  def index
 
  end
  
end