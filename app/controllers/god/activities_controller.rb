class God::ActivitiesController < God::BaseController
  before_filter do
    @check = Check.find(params[:check_id])
    @nav = (@check == curr_check ? :control : :archive)
  end
  
  def index
    @search = @check.activities.valid_s.search(params[:search])
    @activities = @search.order("created_at DESC").paginate(:page => params[:page])
  end
end