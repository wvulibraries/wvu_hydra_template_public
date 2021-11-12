# Audio Player Class
class AudioPlayerController < ApplicationController
  def index
    id = File.basename(params[:id], File.extname(params[:id]))
    audio_record = %%modelname%%.where(id: id).first
    audio_file = audio_record.find_audio[0]
    @mime = audio_file.mime_type
    @audio = audio_file.content
    send_data @audio, filename: id, type: @mime, disposition: 'inline'
  end
end
