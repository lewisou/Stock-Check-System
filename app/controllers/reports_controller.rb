class ReportsController < ApplicationController

  before_filter { @nav = :report }
  
  def count_varience
    @search = Tag.search(params[:search])
    @tags = @search.paginate(:page => params[:page])
  end

  def final_report
    @search = Tag.search(params[:search])
    @tags = @search.paginate(:page => params[:page])
  end

end
