
# get a file to get all the ID's from. 
require 'json'

# puts "Please enter export ID of the file you wish to purge tombstones?"
# export_id = gets.to_s.strip!

# 1549373430 test id
json_file = File.read Rails.root.join('import', '%%abbr%%_export', 'data', '%%abbr%%-data.json')
objects = JSON.parse json_file

ids = objects.map{ |x| x['identifier'] }
ids.each do |id| 
  result = %%modelname%%.eradicate(id)
  puts "Result of eradication on #{id} was #{result} \n"
end 