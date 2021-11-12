require 'fileutils'

# SetupHydraHead
# ==================================================
# Author(s) : David J. Davis, Tracy A. McCormick
# Description:
# Is used to setup the hydra head partials and turn data that is usually manipulated by hand into automated setups.

class SetupHydraHead
  attr_accessor :model, :data_abbr, :collection, :project_name, :page_description, :key_words, :prod_host, :dev_host, :project_name

  # initialize
  # ==================================================
  # Name : David J. Davis
  # Date : 9/16/2017
  # Description :
  # sets all the names based on a initize class
  def initialize setters = {}
    setters.each { |key, value| send "#{key}=", value }
  end

  # generate_files
  # ==================================================
  # Name(s) : David J. Davis, Tracy A. McCormick
  # Date : 9/16/2017
  # Modified : 09/27/2021
  # Description :
  # loops through the replacment folders and replaces the variable names as needed.  
  def generate_files 
    rep_folders = ['controllers', 'models', 'mailers', 'lib', 'import', 'services']
    rep_folders.each do |folder| 
      Dir.glob("../hydra/app/#{folder}/*.rb") do |file|
        replace_file_content(file)
      end
    end
  end  

  # update_files
  # ==================================================
  # Authors : Tracy A. McCormick
  # Date : 9/15/2021
  # Modified : 9/27/2021
  # Description : 
  # updates specific files
  def update_files
    # update enviroments
    replace_file_content('../hydra/config/environments/development.rb')
    replace_file_content('../hydra/config/environments/production.rb')
    replace_file_content('../hydra/config/schedule.rb')
    # update helpers
    replace_file_content('../hydra/app/helpers/application_helper.rb')
    replace_file_content('../hydra/app/helpers/blacklight_helper.rb')
    # update libraries
    replace_file_content('../hydra/lib/import_library.rb')   
    # update model
    replace_file_content('../hydra/app/models/%%modelname%%.rb') 
    # bash scripts
    replace_file_content('../conversion/scripts/cron_convert.sh')    
    # update import script 
    replace_file_content('../hydra/import/import.rb')
  end

  # replace_file_content
  # ==================================================
  # Name : David J. Davis
  # Date : 9/16/2017
  # Description :
  # if is a file it opens it and replaces the content in the file  
  def replace_file_content(file)
    if File.file?(file)
      txt = File.read(file).to_s
      new_content = replacement_filters(txt)
      File.open(file, 'w') { |f| f.puts new_content }
      write_to_feedback_file("Successfully modified #{file}")
    end
  end

  def convert_to_snakecase(camel_cased_string)
    camel_cased_string.to_s.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
  end

  # rename files
  # ==================================================
  # Author : Tracy A. McCormick
  # Date : 9/15/2021
  # Description :
  # rename models to match the model name 
  def rename_model_files
    file_model = "../hydra/app/models/%%modelname%%_file.rb"
    main_model = "../hydra/app/models/%%modelname%%.rb"

    file_model_new = file_model.dup
    file_model_new.gsub!('%%modelname%%', convert_to_snakecase(model))

    main_model_new = main_model.dup
    main_model_new.gsub!('%%modelname%%', convert_to_snakecase(model))    

    File.rename(file_model, file_model_new)
    write_to_feedback_file("Successfully renamed #{file_model} to #{file_model_new}")
    File.rename(main_model, main_model_new)
    write_to_feedback_file("Successfully renamed #{main_model} to #{main_model_new}")
  end 

  # update docker compose files
  # ==================================================
  # Author : Tracy A. McCormick
  # Date : 9/27/2021
  # Updated : 10/06/2021
  # Description :
  # update docker-compose.dev.yml and docker-compose.yml 
  def update_docker_compose
    replace_file_content("../docker-compose.dev.yml")
    replace_file_content("../docker-compose.prod.yml")
    replace_file_content("../docker-compose.yml")
  end 
  
  # replacement_filters
  # ==================================================
  # Author(s) : David J. Davis, Tracy A. McCormick
  # Date : 9/16/2017
  # Modified : 10/01/2021
  # Description :
  # replacing things with gsub  
  def replacement_filters(text)
    text.gsub!('%%modelname%%', model)
    text.gsub!('%%abbr%%', model.downcase)
    text.gsub!('%%collection%%', collection) 
    text.gsub!('%%project_name%%', convert_to_snakecase(model)) 
    text.gsub!('%%page_description%%', page_description) 
    text.gsub!('%%key_words%%', key_words)
    text.gsub!('%%prod_host%%', prod_host)
    text.gsub!('%%dev_host%%', dev_host)
    text
  end

  # replacement_filters
  # ==================================================
  # Name : David J. Davis
  # Date : 9/16/2017
  # Description :
  # writes to a feedback file to let you know whats going on 
  def write_to_feedback_file(message)
    outfile = './results.txt'
    File.open(outfile, 'a') { |f| f.puts message }
  end

  def perform
    generate_files
    update_files
    rename_model_files
    update_docker_compose
  end
  
end # CLASS END
