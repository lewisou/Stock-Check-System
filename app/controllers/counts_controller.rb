require 'ext/tag_table'
require 'ext/spreadsheet'

class CountsController < ApplicationController

  before_filter do
    @c_i = (params[:count] || "1").to_i
    @c_s = "count_#{@c_i.to_s}".to_sym
  end
  
  def frozen_report
    @search = Inventory.in_check(curr_check.id).search(params[:search])
    
    respond_to do |format|
      format.html { @inventories = @search.paginate(:page => params[:page]) }
      format.xls {
        @inventories = @search.all
        book = Spreadsheet::Workbook.new
        data = book.generate_xls("Count #{@c_i} Report", @inventories, %w{Location Item Description FrozenCost Cost FrozenQTY Counted FrozenValue CountedValue}, 
        [[:location, :code], [:item, :code], [:item, :description], [:item, :al_cost], [:item, :cost], :quantity, "counted_in_#{@c_i}".to_sym,
        :frozen_value, "counted_value_in_#{@c_i}".to_sym])
        send_data data, :filename => "Count #{@c_i} Report with Frozen QTY.xls", :disposition => 'attachment'
      }
    end
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
      format.xls {
        @tags = @search.all
        book = Spreadsheet::Workbook.new
        send_data book.render_missing_tags(@tags), :filename => "Missing Tags Count #{@c_i}.xls", :disposition => 'attachment'
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
    
    vals = {
      @c_s => params[:tag][@c_s]
    }
    vals = vals.merge({:sloc => params[:tag][:sloc]}) if @c_i == 1
    
    @tag.update_attributes(vals)

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
