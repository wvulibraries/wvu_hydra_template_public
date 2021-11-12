# Video Player Class
class VideoPlayerController < ApplicationController
  def index
    id = File.basename(params[:id], File.extname(params[:id]))
    video_record = %%modelname%%.where(id: id).first
    @mime = video_record.video_file.mime_type
    @video = video_record.video_file.content
    send_data @video, filename: id, type: @mime, disposition: 'inline'
  end
end
