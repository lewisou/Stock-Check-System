require 'ext/tag_table'
require 'ext/spreadsheet'

class Adm::CountsController < Adm::BaseController
  layout "tags"

  before_filter do
    @c_i = (params[:count] || "1").to_i
    @c_s = "count_#{@c_i.to_s}".to_sym
  end

  def missing_tag
    @search = Tag.in_check(curr_check.id).not_finish(@c_i).countable.search(params[:search])

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

  def result
    @search = Tag.in_check(curr_check.id).countable.where(@c_s.gte % 0).search(params[:search])
    @tags = @search.paginate(:page => params[:page])
  end
end