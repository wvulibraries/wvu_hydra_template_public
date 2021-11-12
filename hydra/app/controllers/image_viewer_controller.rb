# Image Viewer Class
class ImageViewerController < ApplicationController
  ## gets image and shows image
  def index
    id = File.basename(params[:id], File.extname(params[:id]))
    image_model = %%modelname%%.where(id: id).first
    @image = image_model.image_file.content
    render 'index.jpg.erb'
  end

  ## gets image and shows image
  def thumb
    id = File.basename(params[:id], File.extname(params[:id]))
    image_model = %%modelname%%.where(id: id).first
    @thumb = image_model.thumbnail_file.content
    render 'thumb.jpg.erb'
  end
end