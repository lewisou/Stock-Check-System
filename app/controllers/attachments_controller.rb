class AttachmentsController < ApplicationController
  def show
    @attachment = Attachment.find(params[:id])
    send_file @attachment.data.path, :filename => @attachment.data_file_name, :type => :xls, :disposition => 'attachment'
  end
end
