require 'ext/tag_table'

class Adm::WaitPrintsController < Adm::BaseController
  layout "tags"
  
  before_filter do
    @sub_menu = :print_list
  end
  
  def destroy
    @tag = Tag.in_check(curr_check.id).find(params[:id])
    
    if @tag.update_attributes(:wait_for_print => false)
      redirect_to adm_wait_prints_path, :notice => "Successfully removed."
    else
      redirect_to adm_wait_prints_path, :alert => "Failed to remove."
    end
  end
  
  def update
    @tag = Tag.in_check(curr_check.id).find(params[:id])
    
    if @tag.update_attributes(:wait_for_print => true)
      redirect_to adm_wait_prints_path, :notice => "Successfully added."
    else
      redirect_to adm_tags_path, :alert => "Failed to add."
    end
  end
  
  def index
    @search = Tag.in_check(curr_check.id).where(:wait_for_print => true).search(params[:search])
    
    respond_to do |format|
      format.html { @tags = @search.paginate(:page => params[:page]) }

      format.pdf {
        @tags = @search.all

        pdf = Prawn::Document.generate_tags @tags
        send_data pdf.render, :filename => "tickets.pdf", :disposition => 'attachment'
      }
    end
    
  end
end