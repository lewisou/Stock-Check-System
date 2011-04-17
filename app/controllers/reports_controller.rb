require 'ext/tag_table'
require 'ext/spreadsheet'
require 'pp'

class ReportsController < ApplicationController
  before_filter { @nav = :report }
  
  def count_varience
    @count_3_finished = !params[:count_3_finished].blank?

    @search = Tag.in_check(curr_check.id).where(:count_1.gte % 0 & :count_2.gte % 0)

    if @count_3_finished
      @search = @search.where(:count_3.not_eq % nil) 
    else
      @search = @search.where(:count_3.eq % nil)
    end
    
    @search = @search.search(({"tolerance_v" => 25, "tolerance_q" => 5}).merge(params[:search] || {}))

    
    respond_to do |format|
      format.html { @tags = @search.paginate(:page => params[:page]) }
      
      format.xls {
        @tags = @search.all
        book = Spreadsheet::Workbook.new
        send_data book.render_tags(@tags, "Tags Need Count 3"), :filename => "Tags_need_Count_3.xls", :disposition => 'attachment'
      }
    end

  end

  def final_report
    @search = Tag.in_check(curr_check.id).where(:count_1.gte % 0 & :count_2.gte % 0).search(params[:search])
    
    respond_to do |format|
      format.html { @tags = @search.paginate(:page => params[:page]) }
      
      format.xls {
        @tags = @search.all
        book = Spreadsheet::Workbook.new
        send_data book.render_tags(@tags, "Final Report"), :filename => "Final Report.xls", :disposition => 'attachment'
      }
    end

  end
  
  def final_frozen
    @search = Inventory.in_check(curr_check.id).search(params[:search])

    respond_to do |format|
      format.html { @inventories = @search.paginate(:page => params[:page]) }
      
      format.xls {
        @inventories = @search.all
        book = Spreadsheet::Workbook.new
        send_data book.render_inventories(@inventories, "Final Report with Frozen QTY"), :filename => "Final Report with Frozen QTY.xls", :disposition => 'attachment'
      }
    end

  end

end
