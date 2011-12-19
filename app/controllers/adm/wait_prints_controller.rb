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
      redirect_to adm_wait_prints_path, :notice => "One ticket successfully added."
    else
      redirect_to adm_tags_path, :alert => "Failed to add."
    end
  end

  def multiple_create
    @search = Tag.in_check(curr_check.id).countable.where(:wait_for_print => false).readonly(false).search(params[:search])
    count = @search.count

    @search.each { |tag|
      tag.update_attributes(:wait_for_print => true)
    }

    redirect_to adm_wait_prints_path, :notice => "#{count} tickets successfully added."
  end

  def index
    @search = Tag.in_check(curr_check.id).where(:wait_for_print => true).search(params[:search])

    respond_to do |format|
      format.html { @tags = @search.paginate(:page => params[:page]) }
      format.js {
        file = StringIO.new(Prawn::Document.generate_tags(@search.all).render)
        file.class.class_eval { attr_accessor :original_filename, :content_type } #add attr's that paperclip needs
        file.original_filename = "generated_pdf_#{curr_check.generated_pdfs.count + 1}.pdf"
        file.content_type = "application/pdf"

        @attachment = ::Attachment.create(:data => file)
        curr_check.generated_pdfs << @attachment

        render :partial => 'adm/wait_prints/download_link', :locals => {:attachment => @attachment}
        # send_data pdf.render, :filename => "tickets.pdf", :disposition => 'attachment'
      }
    end
  end
end
