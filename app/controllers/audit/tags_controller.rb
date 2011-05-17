require 'ext/spreadsheet'

class Audit::TagsController < Audit::BaseController
  before_filter do
    @nav = :audit
  end

  def edit
    @tag = Tag.in_check(curr_check.id).countable.find(params[:id])
  end

  def index
    @search = Tag.in_check(curr_check.id).countable.includes(:inventory => :item, :inventory => :location).search(params[:search])
    @tags = @search.paginate(:page => params[:page])
  end
  
  def update
    @tag = Tag.in_check(curr_check.id).countable.find(params[:id])
    
    if @tag.update_attributes(params[:tag])
      redirect_to audit_tags_path, :notice => "Audit updated."
    else
      render :edit
    end
  end
end