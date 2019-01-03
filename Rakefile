# Use the slack_config.json file! No user serviceable parts below here! 

require 'open-uri'
require 'uri'
require 'json'

config_file  = File.read('slack_config.json')
config = JSON.parse(config_file)
archive_uri = URI.parse(config["hipchat_archive_url"])
archive_filename = File.basename(archive_uri.path)
archive_dir_name = File.basename(archive_filename, ".tar.gz.aes")
archive_dir = "#{config["hipchat_archive_location"]}/hipchat-export"


desc "Process the rooms and users; delete unneeded history."
task :run do

   Rake::Task["room_setup"].invoke
   Rake::Task["user_setup"].invoke
   Rake::Task["room_delete"].invoke
  
end

desc "Read the spreadsheet and set up the rooms.json file." 
task :room_setup do 

  puts "Reading the spreadsheet and setting up the rooms.json file ..." 
  `ruby rooms.rb`
end

desc "Make adjustments to users.json"
task :user_setup do
  puts "Making adjustments to users.json ..."
  `ruby users.rb`
end


desc "Delete history for unmigrated rooms."
task :room_delete do 
  puts "Deleting history for unmigrated rooms ..."
  `ruby delete_files.rb`
end

desc "Repack the archive."
task :repack do

  puts "This will put an encrypted tarball with the original password in your current working directory."
  puts "Repacking the archive ..."

  # "hipchat_archive_location": "/Users/Mike/slack/export",
  tarball = "#{config["hipchat_archive_location"]}/#{config["tarball_name"]}"

  # "hipchat_archive_location": "/Users/Mike/slack/export",
  # File.basename(archive_filename, ".tar.gz.aes")
  
  `tar -czf #{__dir__}/#{config["tarball_name"]} -C #{archive_dir}/ .`  
#  `gzip -q #{__dir__}/#{config["tarball_name"]}`
  puts "Encrypting the archive ... "
  `openssl enc -aes-256-cbc -md md5 -in #{config["tarball_name"]} -out #{config["hipchat_archive_name"]} -k #{config["hipchat_archive_password"]}`
  
end


namespace "setup" do
  
  
  
desc "Download the latest HipChat archive."
task :download_archive do 
    
  puts "Downloading the latest HipChat archive (this'll take a while ...)"
  download_loc = config["hipchat_archive_location"] + "/" + config["hipchat_archive_name"]
    
  File.open(download_loc , "wb") do |saved_file|
    open(config["hipchat_archive_url"], "rb") do |read_file|
      saved_file.write(read_file.read)
    end
  end
end

desc "Clean out the sandbox and unpack the archive."
task :unpack do

  tarball = "#{config["hipchat_archive_location"]}/#{config["tarball_name"]}"

  puts "Cleaning out the sandbox and unpacking a fresh copy ..."  

  if File.directory?(archive_dir)
    puts "Removing archive dir ..."
    `rm -rf #{archive_dir}`
  end

  puts "Decrypting ..."
  `openssl aes-256-cbc -d -in #{config["hipchat_archive_location"]}/#{config["hipchat_archive_name"]} -out #{config["hipchat_archive_location"]}/#{config["tarball_name"]} -pass pass:#{config["hipchat_archive_password"]}`
  puts "Making archive dir ... "
  # archive_dir = "#{config["hipchat_archive_location"]}/hipchat-export"
  `mkdir #{archive_dir}`
  puts "Unpacking tarball ..."
  `tar xzf #{tarball} -C #{archive_dir}`
  
  end
end