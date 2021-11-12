# Import library for both automatic and manual imports
# @author Tracy A. McCormick
# @return [Boolean]
# 
# ================================================================================
module ImportLibrary
  def self.create_new_record(obj)  
      # create the new record
      %%modelname%%.create(obj.except(:image_path, :thumb_path, :audio_path, 
      :video_path, :video_image_path, :video_thumb_path, 
      :pdf_path, :pdf_image_path, :pdf_thumb_path))
  end

  def self.set_file(file_obj, type, path)
      file_obj.mime_type = type
      file_obj.content = File.open(path)
      file_obj.original_name = path
  end     

  # importing the record
  def self.import_record(id, obj)   
      begin
        retries ||= 0
  
        jpg_path = obj[:image_path]
        thumb_path = obj[:thumb_path]
        audio_path = obj[:audio_path]
        video_path = obj[:video_path]
        video_image_path = obj[:video_image_path]
        video_thumb_path = obj[:video_thumb_path]
        pdf_path = obj[:pdf_path]
        pdf_image_path = obj[:pdf_image_path]
        pdf_thumb_path = obj[:pdf_thumb_path]
    
        new_record = create_new_record(obj)
    
        new_record.files.build
        set_file(new_record.build_image_file, 'application/jpg', jpg_path) if File.exist?(jpg_path.to_s)
        set_file(new_record.build_thumbnail_file, 'application/jpg', thumb_path) if File.exist?(thumb_path.to_s)
        set_file(new_record.build_pdf_file, 'application/pdf', pdf_path) if File.exist?(pdf_path.to_s)
        set_file(new_record.build_image_file, 'application/jpg', pdf_image_path) if File.exist?(pdf_image_path.to_s)
        set_file(new_record.build_thumbnail_file, 'application/jpg', pdf_thumb_path) if File.exist?(pdf_thumb_path.to_s)
        set_file(new_record.build_audio_file, 'audio/mpeg', audio_path) if File.exist?(audio_path.to_s)
        set_file(new_record.build_video_file, 'video/mp4', video_path) if File.exist?(video_path.to_s)
        set_file(new_record.build_image_file, 'application/jpg', video_image_path) if File.exist?(video_image_path.to_s)
        set_file(new_record.build_thumbnail_file, 'application/jpg', video_thumb_path) if File.exist?(video_thumb_path.to_s) 
  
        new_record.save
      rescue RuntimeError => e
        puts "Error: #{e} - retrying record creation"
  
        # if tombstone exists, delete it
        if e.message.include? "Can't call create on an existing resource"
          # get resource id from error message
          uri = e.message.split("(").last.split(")").first
  
          puts "deleting record and tombstone from fedora and retrying create"
          # try to use curl to delete the record and tombstone
          %x{ curl -X DELETE #{uri} }
          %x{ curl -X DELETE #{uri}/fcr:tombstone }
        else
          # delete tombstone from fedora
          result = %%modelname%%.eradicate(id)
          puts "Result of eradication on #{id} was #{result} \n"
        end
        retry if (retries += 1) < 3
      end  
  end

  def self.update_file(file_obj, type, path)
      file_obj.mime_type = type
      file_obj.content = File.open(path)
      file_obj.original_name = path
      file_obj.save
  end      
    
  # update the record
  def self.update_record(updated_record, obj)
    jpg_path = obj[:image_path]
    thumb_path = obj[:thumb_path]
    audio_path = obj[:audio_path]
    video_path = obj[:video_path]
    video_image_path = obj[:video_image_path]
    video_thumb_path = obj[:video_thumb_path]
    pdf_path = obj[:pdf_path]
    pdf_image_path = obj[:pdf_image_path]
    pdf_thumb_path = obj[:pdf_thumb_path]

    updated_record.update(obj.except(:image_path, :thumb_path, :audio_path, 
                                :video_path, :video_image_path, :video_thumb_path, 
                                :pdf_path, :pdf_image_path, :pdf_thumb_path))

    if File.exist?(jpg_path)
      image_file = updated_record.image_file
      if image_file.nil?
        set_file(updated_record.build_image_file, 'application/jpg', jpg_path)
      else
        update_file(image_file, 'application/jpg', jpg_path)
      end
    end

    if File.exist?(thumb_path)
      thumb_file = updated_record.thumbnail_file
      if thumb_file.nil?  
        set_file(updated_record.build_thumbnail_file, 'application/jpg', thumb_path)
      else
        update_file(thumb_file, 'application/jpg', thumb_path)
      end
    end

    if File.exist?(pdf_path)
      pdf_file = updated_record.pdf_file
      if pdf_file.nil?
        set_file(updated_record.build_pdf_file, 'application/pdf', pdf_path)
      else
        update_file(pdf_file, 'application/pdf', pdf_path)
      end
    end

    if File.exist?(pdf_image_path)
      pdf_image_file = updated_record.image_file
      if pdf_image_file.nil?
        set_file(updated_record.build_image_file, 'application/jpg', pdf_image_path)
      else
        update_file(pdf_image_file, 'application/jpg', pdf_image_path)
      end
    end   

    if File.exist?(pdf_thumb_path)
      pdf_thumb_file = updated_record.thumbnail_file
      if pdf_thumb_file.nil?
        set_file(updated_record.build_thumbnail_file, 'application/jpg', pdf_thumb_path)
      else
        update_file(pdf_thumb_file, 'application/jpg', pdf_thumb_path)
      end
    end

    if File.exist?(audio_path)
      audio_file = updated_record.audio_file
      if audio_file.nil?
        set_file(updated_record.build_audio_file, 'audio/mpeg', audio_path)
      else
        update_file(audio_file, 'audio/mpeg', audio_path)
      end
    end

    if File.exist?(video_path)
      video_file = updated_record.video_file
      if video_file.nil? 
        set_file(updated_record.build_video_file, 'application/jpg', video_path)
      else
        update_file(video_file, 'application/jpg', video_path)
      end
    end

    if File.exist?(video_image_path)
      video_image_file = updated_record.image_file
      if video_image_file.nil?
        set_file(updated_record.build_image_file, 'application/jpg', video_image_path)
      else
        update_file(video_image_file, 'application/jpg', video_image_path)
      end
    end

    if File.exist?(video_thumb_path)
      video_thumb_file = updated_record.thumbnail_file
      if video_thumb_file.nil?
        set_file(updated_record.build_thumbnail_file, 'application/jpg', video_thumb_path)
      else
        update_file(video_thumb_file, 'application/jpg', video_thumb_path)
      end
    end

    updated_record.save
  end      

  # Checks if a file named with the idno is present
  # If it is, it will return the path to the file
  # If it is not, it will return identifier file path.
  # @return String
  # @author Tracy A McCormick
  # Created: 09/18/2021
  def self.find_file_name(path, idno, identifier, extension)
    idno_file = "#{path}/#{idno}.#{extension}"
    identifier_file = "#{path}/#{identifier}.#{extension}"
    File.exist?(idno_file) ? idno_file : identifier_file
  end    
  
  def self.modify_record(export_path, record)  
    # find correct video basename for import
    # collection doesn't always have video filename that matches identifier exactly.
    # so we need to find the correct video filename
    videofile = Dir["#{export_path}/video/#{record['identifier']}_*.mp4"].first
    videobasename = videofile.nil? ? record['identifier'] : File.basename(videofile, File.extname(videofile))
    
    puts "Setting videobasename: #{videobasename} in modify record"

    # modify each record
    {
      # insert fields here

      # end of insert fields
      
      project: ['%%abbr%%', '%%collection%%'],
      read_groups: ['public'],
      image_path: find_file_name("#{export_path}/jpg", record['idno'], record['identifier'], "jpg"),
      thumb_path: find_file_name("#{export_path}/thumbs", record['idno'], record['identifier'], "jpg"),
      audio_path: find_file_name("#{export_path}/audio", record['idno'], record['identifier'], "mp3"),
      video_path: "#{export_path}/video/#{videobasename}.mp4",
      video_image_path: "#{export_path}/videoimages/#{videobasename}.jpg",
      video_thumb_path: "#{export_path}/videothumbs/#{videobasename}.jpg",
      pdf_path: find_file_name("#{export_path}/pdf", record['idno'], record['identifier'], "pdf"),
      pdf_image_path: find_file_name("#{export_path}/pdfimages", record['idno'], record['identifier'], "jpg"),
      pdf_thumb_path: find_file_name("#{export_path}/pdfthumbs", record['idno'], record['identifier'], "jpg")
    }
  end  

end