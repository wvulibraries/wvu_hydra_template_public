require 'json'

# SetupCatalogController
# ==================================================
# Author(s) : Tracy A. McCormick
# Date      : 10/15/2021
# Description:
# Is used to setup the hydra head partials and turn data that is usually manipulated by hand into automated setups.
class SetupCatalogController
  def initialize()
    @controller_path = "../hydra/app/controllers/catalog_controller.rb"

    # set manual export path
    @export_path = Dir.glob("../mfcs_export/*").last

    @facet = "config.add_facet_field solr_name('%%solr_name%%', :facetable), :label => '%%solr_label%%', :limit => 10"
  end

  def find_insert_line(str)
    input  = File.open(@controller_path, 'r')
    lines = input.readlines
    count = 0
    lines.each do |line|
      if line.include? str
        return count
      end
      count += 1
    end  
  end

  def camel_case(str)
    str.split('_').map{|e| e.capitalize}.join
  end

  # def write_after_insert_here(original_file, new_file, new_content)
  #   File.open(new_file, 'w') do |file|
  #     IO.foreach(original_file) do |line|
  #       file.write(line)
  #       if line.include? '# insert fields here'
  #         new_content.each do |key, value|
  #           if value == "array"
  #             file.write("      #{key}: HydraFormatting.split_subjects(record['#{key}']),\n")
  #           else
  #             file.write("      #{key}: HydraFormatting.valid_string(record['#{key}']),\n")
  #           end
  #         end          
  #       end
  #     end
  #   end
  # end

  # def process_json_file(json_file)
  #   # parse the json file
  #   @objects = JSON.parse json_file
  #   # set objects
  #   @items = Hash.new
  #   @objects.each do |record|
  #     begin
  #       record.each do |key, value|
  #         # if value has ||| then field is an array
  #         if value.to_s.include?("|||")
  #           @items["#{key}"] = "array"
  #         else 
  #           @items["#{key}"] = "string"
  #         end 
  #       end
  #     rescue RuntimeError => e
  #       abort "Error (#{e})"
  #     end
  #   end

  #   write_after_insert_here(@library_template_path, @library_path, @items) 
  # end  

  def process_json_file(json_file)
    # parse the json file
    objects = JSON.parse json_file

    line_number = find_insert_line('# facet creator')

    input  = File.open(@controller_path, 'r')
    lines = input.readlines

    output = File.open(@controller_path, 'w')
    count = 0
    done = false

    lines.each do |line|
      if count == line_number+1 && done == false
        objects[1].each do |key, value|
          output.write("   #{@facet}\n".gsub('%%solr_name%%', key).gsub('%%solr_label%%', key.capitalize))
          count += 1    
        end         
        done = true
      end
      output.write(line)
      count += 1
    end    
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