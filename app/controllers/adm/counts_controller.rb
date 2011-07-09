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

        data = book.generate_xls(
        "Missing Tags Count #{@c_i}", @tags,        
        ['Tag #', 'Item #', 'Warehouse', 'Shelf Location', @c_s.to_s],
        [:id, [:inventory, :item, :code], [:inventory, :location, :code], :sloc, @c_s]
        )

        send_data data, :filename => "Missing Tags Count #{@c_i}.xls", :disposition => 'attachment'
      }

    end
  end

  def result
    @search = Tag.in_check(curr_check.id).countable.where(@c_s.gte % 0).search(params[:search])

    respond_to do |format|
      format.html { 
        @tags = @search.paginate(:page => params[:page])
      }
      format.xls {
        @tags = @search.all
        book = Spreadsheet::Workbook.new
        data = book.generate_xls("Count #{@c_s} Result", @tags, 
        %w{TagNumber ItemNumber Description Warehouse ShelfLocation Count},
        [:id,
        [:inventory, :item, :code], 
        [:inventory, :item, :description],
        [:inventory, :location, :code],
        :sloc,
        @c_s])
        send_data data, :filename => "Count #{@c_i} Result.xls", :disposition => 'attachment'
      }
    end
  end
end