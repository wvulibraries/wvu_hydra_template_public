#!/bin/env ruby

require "#{Rails.root}/lib/import_library.rb"

class Import
  include ImportLibrary

  def initialize
    puts 'This will import the current export into fedora and solr in your current environment ... are you sure you want to do this? (Yes, No)'
    run
  end

  def parse_data(json_file)
    # parse the json file
    @objects = JSON.parse json_file
    # set objects
    @objects.each do |record|
      begin
        # skip record if EXCLUDE is in title
        next if record['title'].include?("EXCLUDE")

        id = record['idno'].to_s.empty? ? record['identifier'] : record['idno']

        # remove . in identifier
        id = id.gsub('.', '').to_s
   
        puts "Processing #{id}"

        # record exists
        record_exists = %%modelname%%.where(id: id).first

        if record_exists.nil?
          puts "Inserting Record (#{id})"
          ImportLibrary.import_record(id, ImportLibrary.modify_record(@export_path, record))
        else          
          puts "Updating Record (#{id})"
          ImportLibrary.update_record(record_exists, ImportLibrary.modify_record(@export_path, record))
        end
      rescue RuntimeError => e
        puts "Record (#{id})"
        abort "Error (#{e})"
      end
    end
  end        

  def run
    # parse the json file  
    @export_path = Dir.glob("/mfcs_export/*").last
    puts "Importing from #{@export_path}"

    # find the json file in the directory
    matched_files = Dir["#{@export_path}/data/*-data.json"]

    if File.exist?(matched_files.first)
      # read and parse the json file
      parse_data(File.read matched_files[0])
    else
      abort "No data file found"
    end
  end

  def prompt
    result = gets.to_s
    result.downcase!
    result.strip!
    result.empty? ? 'no' : result
  end  

  def perform
    answer = prompt.downcase
    if %w[yes y 1 true].include? answer
      run
      puts "We performed the current import because you answered - #{answer}"
    else
      abort "Import was not performed, your answer was #{answer}"
    end
  end
end

Import.new
