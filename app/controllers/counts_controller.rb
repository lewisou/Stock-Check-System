require 'ext/tag_table'

class CountsController < ApplicationController

  before_filter do
    @c_i = (params[:count] || "1").to_i
    @c_s = "count_#{@c_i.to_s}".to_sym
  end
  
  def missing_tag
    @search = Tag.in_check(curr_check.id).not_finish(@c_i).search(params[:search])

    respond_to do |format|
      format.html { @tags = @search.paginate(:page => params[:page]) }

      format.pdf {
        @tags = @search.all

        pdf = Prawn::Document.generate_tags @tags
        send_data pdf.render, :filename => "tags.pdf", :disposition => 'attachment'
      }
    end


  end

  def index
    @search = Tag.in_check(curr_check.id).search(params[:search])
    
    if @search.count == 1
      @tag = @search.first
    end
  end

  def update
    @tag = Tag.in_check(curr_check.id).find(params[:id])
    @tag.update_attributes(@c_s => params[:tag][@c_s])

    if @tag.save
      redirect_to(counts_path(:search => {:id_eq => @tag.id}, :count => @c_i), :notice => "Count #{params[:count]} updated.")
    else
      render :index
    end
  end
  
  def result
    @search = Tag.in_check(curr_check.id).where(@c_s.gte % 0).search(params[:search])
    @tags = @search.paginate(:page => params[:page])
  end
end
