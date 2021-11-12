require 'fileutils'

# grab the arguments passed in by the script 
project_name = ARGV[0]

# abort if the 
abort "Missing project name" if project_name.nil? 
control_dir = "/mnt/nfs-exports/mfcs-exports/#{project_name}/control/mfcs"
process_dir = "/mnt/nfs-exports/mfcs-exports/#{project_name}/control/hydra/in-progress"
process_finished_dir = "/mnt/nfs-exports/mfcs-exports/#{project_name}/control/hydra/finished"
process_failed_dir = "/mnt/nfs-exports/mfcs-exports/#{project_name}/control/hydra/failed"
conversion_process_dir = "/mnt/nfs-exports/mfcs-exports/#{project_name}/control/conversion/in-progress"
conversion_finished_dir = "/mnt/nfs-exports/mfcs-exports/#{project_name}/control/conversion/finished"

# create the directories if they don't exist
FileUtils.mkdir_p(control_dir) unless File.exists?(control_dir)
FileUtils.mkdir_p(process_dir) unless File.exists?(process_dir)
FileUtils.mkdir_p(process_finished_dir) unless File.exists?(process_finished_dir)
FileUtils.mkdir_p(process_failed_dir) unless File.exists?(process_failed_dir)
FileUtils.mkdir_p(conversion_process_dir) unless File.exists?(conversion_process_dir)
FileUtils.mkdir_p(conversion_finished_dir ) unless File.exists?(conversion_finished_dir )

# if there is already a control file in the processing directory, exit
if Dir.entries(process_dir).length > 2
  puts "processing already in process"
  exit 
end 

Dir.open(control_dir).sort.each do |file|
  next if file == '.' || file == '..'
  control_file = YAML.load_file "#{control_dir}/#{file}"
  AutomaticImportJob.perform_now control_file
  break
end