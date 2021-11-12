require 'json'

# SetupModelFile
# ==================================================
# Author(s) : Tracy A. McCormick
# Date      : 09/29/2021
# Description:
# Is used to setup the hydra head partials and turn data that is usually manipulated by hand into automated setups.
class SetupModelFile
  def initialize()
    @model_path = "../hydra/app/models/%%modelname%%.rb"

    @dc_terms = %w(contributor coverage creator date description format identifier language publisher relation rights source subject title type extent)

    # set manual export path
    @export_path = Dir.glob("../mfcs_export/*").last

    @predicate = "::RDF::Vocab::DC.%%key%%"
    @custom_predicate = "::RDF::URI.intern('http://lib.wvu.edu/hydra/%%custom_key%%')"
  
    @line1 = "# DC %%key%%"
    @line2 = "# =============================================================================================================="
    @line3 = "# %%key%% property"
    @line4 = "property :%%key%%, predicate: %%predicate%%, multiple: %%array_detected%% do |index|"
    @line5 = "  index.as :stored_searchable, :stored_sortable, :facetable"
    @line6 = "end"
  end

  def find_insert_line()
    input  = File.open(@model_path, 'r')
    lines = input.readlines
    count = 0
    lines.each do |line|
      if line.include? "# insert fields here"
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
    # set objects
    items = Hash.new
    objects.each do |record|
      begin
        record.each do |key, value|
          # if value has ||| then field is an array
          if value.to_s.include?("|||")
            items["#{key}"] = "true"
          else 
            items["#{key}"] = "false"
          end 
          #puts "#{key} => #{value}"
        end
      rescue RuntimeError => e
        abort "Error (#{e})"
      end
    end

    line_number = find_insert_line()

    input  = File.open(@model_path, 'r')
    lines = input.readlines

    output = File.open(@model_path, 'w')
    count = 0
    done = false

    lines.each do |line|
       if count == line_number+1 && done == false
        # add the fields to the import file
        items.each do |key, value|
          output.write("  #{@line1}\n".gsub('%%key%%', key.capitalize))
          output.write("  #{@line2}\n")
          output.write("  #{@line3}\n".gsub('%%key%%', key))

          # if key is in predicates array then predicate else use custom predicate
          if @dc_terms.include?(key)
            predicate = @predicate.gsub('%%key%%', key) 
            output.write("  #{@line4}\n".gsub('%%key%%', key).gsub('%%predicate%%', predicate).gsub('%%array_detected%%', value))
          else
            custom_predicate = @custom_predicate.gsub('%%custom_key%%', camel_case(key))
            output.write("  #{@line4}\n".gsub('%%key%%', key).gsub('%%predicate%%', custom_predicate).gsub('%%array_detected%%', value))
          end

          output.write("  #{@line5}\n")
          output.write("  #{@line6}\n")
          output.write("\n")
          count += 7
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