class AttachmentsController < ApplicationController
  def show
    @attachment = Attachment.find(params[:id])
    send_file @attachment.data.path, :filename => @attachment.data_file_name, :type => @attachment.data_content_type, :disposition => 'inline'
  end

  def download
    @attachment = Attachment.find(params[:id])
    # send_file @attachment.data.path, :filename => @attachment.data_file_name, :type => :xls, :disposition => 'attachment'
    send_file @attachment.data.path, :filename => @attachment.data_file_name, :type => @attachment.data_content_type, :disposition => 'attachment'
  end
end
