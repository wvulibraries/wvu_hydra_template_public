require 'json'

# SetupImportFiles
# ==================================================
# Author(s) : Tracy A. McCormick
# Modified : October 1, 2021
# Description :
# Is used to setup the hydra head partials and turn data that is usually manipulated by hand into automated setups.
class SetupImportFiles
  def initialize()
    @library_template_path = "../hydra/lib/import_library_template.rb"
    @library_path = "../hydra/lib/import_library.rb"

    @hydra_array = "HydraFormatting.split_subjects"
    @hydra_text = "HydraFormatting.remove_special_chars"

    # parse the json file  
    @export_path = Dir.glob("../mfcs_export/*").last
  end

  def write_after_insert_here(original_file, new_file, new_content)
    File.open(new_file, 'w') do |file|
      IO.foreach(original_file) do |line|
        file.write(line)
        if line.include? '# insert fields here'
          new_content.each do |key, value|
            if value == "array"
              file.write("      #{key}: HydraFormatting.split_subjects(record['#{key}']),\n")
            else
              file.write("      #{key}: HydraFormatting.valid_string(record['#{key}']),\n")
            end
          end          
        end
      end
    end
  end

  def process_json_file(json_file)
    # parse the json file
    @objects = JSON.parse json_file
    # set objects
    @items = Hash.new
    @objects.each do |record|
      begin
        record.each do |key, value|
          # if value has ||| then field is an array
          if value.to_s.include?("|||")
            @items["#{key}"] = "array"
          else 
            @items["#{key}"] = "string"
          end 
        end
      rescue RuntimeError => e
        abort "Error (#{e})"
      end
    end

    write_after_insert_here(@library_template_path, @library_path, @items) 
  end

  def perform
    puts "Reading From #{@export_path}"

    # find the json file in the directory
    matched_files = Dir["#{@export_path}/data/*-data.json"]

    if File.exist?(matched_files.first)
        # read and parse the json file
        process_json_file(File.read matched_files[0])
    else
        abort "No data file found"
    end
  end  
end