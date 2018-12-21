#!/usr/bin/env ruby

require 'json'
require 'fileutils'
require 'uri'

config_file  = File.read('slack_config.json')
config = JSON.parse(config_file)
archive_uri = URI.parse(config["hipchat_archive_url"])
archive_filename = File.basename(archive_uri.path)
archive_dir_name = File.basename(archive_filename, ".tar.gz.aes")
export_root =    config["hipchat_archive_location"] + "/#{archive_dir_name}"

room_content_dir = export_root + "/rooms/*"
rooms_file = File.read(export_root + "/rooms.json")
rooms = JSON.parse(rooms_file)

rooms_list = []

rooms.each do |r|
  rooms_list << r["Room"]["id"].to_s
end

dir_list = Dir[room_content_dir]

dir_list.each do |f|
  
  id_to_find =  File.basename(f)
  
  if rooms_list.include?(id_to_find.to_s)

    puts "Found this one ... I'd keep it. #{id_to_find}"  
      
  else
    FileUtils.rm_rf(f)    
    puts "Couldn't find this one ... I will delete #{f}"

  end
  
  

end

