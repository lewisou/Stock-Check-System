require 'ext/tag_table'
require 'ext/spreadsheet'

class CountsController < ApplicationController

  before_filter do
    @c_i = (params[:count] || "1").to_i
    @c_s = "count_#{@c_i.to_s}".to_sym

    check_role(:dataentry)

    if @c_i <= 2
      check_data_entry
    end

    @nav = :count
  end

  def index
    @search = Tag.in_check(curr_check.id).countable.search(params[:search])
    
    if @search.count == 1
      @tag = @search.first
    end
  end

  def update
    @tag = Tag.in_check(curr_check.id).countable.find(params[:id])
    
    vals = {
      @c_s => params[:tag][@c_s]
    }
    # vals = vals.merge({:sloc => params[:tag][:sloc]}) if @c_i == 1
    
    @tag.update_attributes(vals)

    if @tag.save
      redirect_to(count_path(@tag, :count => @c_i), :notice => "Ticket No.#{@tag.id} of Count #{params[:count]} was updated to #{@tag.send(@c_s)}.")
    else
      render :index
    end
  end

  def show
    @tag = Tag.in_check(curr_check.id).countable.find(params[:id])
    @search = Tag.in_check(curr_check.id).countable.search(params[:search])
  end

end
