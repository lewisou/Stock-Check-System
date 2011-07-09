class Dataentry::ItemsController < Dataentry::BaseController
  before_filter do
    @nav = :remote_input
  end

  def index
    @search = curr_check.items.search(params[:search])
    @items = @search.paginate(:page => params[:page])
  end
end
