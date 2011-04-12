require 'ext/tag_table'

class PrintsController < ApplicationController
  def index
    @search = Tag.search(params[:search])
    @tags = @search.paginate(:page => params[:page], :include => :location, :include => :part)
    
    pdf = Prawn::Document.generate_tags @tags
    send_data pdf.render, :filename => 'tags.pdf', :disposition => 'attachment'
  end
end
