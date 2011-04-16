require 'ext/tag_table'

class ReportsController < ApplicationController
  before_filter { @nav = :report }
  
  def count_varience
    @search = Tag.in_check(curr_check.id).where(:count_1.gte % 0 & :count_2.gte % 0).search(params[:search])

    respond_to do |format|
      format.html { @tags = @search.paginate(:page => params[:page]) }

      format.pdf {
        @tags = @search.all

        pdf = Prawn::Document.generate_tags @tags
        send_data pdf.render, :filename => "tags.pdf", :disposition => 'attachment'
      }
    end
    
  end

  def final_report
    @search = Tag.in_check(curr_check.id).where(:count_1.gte % 0 & :count_2.gte % 0).search(params[:search])
    @tags = @search.paginate(:page => params[:page])
  end
  
  def final_frozen
    @search = Inventory.in_check(curr_check.id).search(params[:search])
    @inventories = @search.paginate(:page => params[:page])
  end

end
