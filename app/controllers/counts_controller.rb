class CountsController < ApplicationController

  before_filter do
    @c_i = (params[:count] || "1").to_i
    @c_s = "count_#{@c_i.to_s}".to_sym
  end
  
  def missing_tag
    @search = Tag.where(@c_s.eq % nil | @c_s.eq % 0).search(params[:search])
    @tags = @search.paginate(:page => params[:page])
  end

  def index
    @search = Tag.search(params[:search])
    
    if @search.count == 1
      @tag = @search.first
    end
  end

  def update
    @tag = Tag.find(params[:id])
    @tag.update_attributes(@c_s => params[:tag][@c_s])

    if @tag.save
      redirect_to(counts_path(:search => {:id_eq => @tag.id}, :count => @c_i), :notice => "Count #{params[:count]} updated.")
    else
      render :index
    end
  end
  
  def result
    @search = Tag.where(@c_s.gte % 0).search(params[:search])
    @tags = @search.paginate(:page => params[:page])
  end
end
