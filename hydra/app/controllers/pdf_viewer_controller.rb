# Pdf Viewer Class
class PdfViewerController < ApplicationController
  def index
    id = File.basename(params[:id], File.extname(params[:id]))
    pdf_record = %%modelname%%.where(id: id).first
    @pdf = pdf_record.pdf_file.content
    send_data @pdf, filename: id, type: 'application/pdf', disposition: 'inline'
  end
end
