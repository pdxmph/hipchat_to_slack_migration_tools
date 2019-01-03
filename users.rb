#!/usr/bin/env ruby

require "json"
require 'uri'

config_file  = File.read('slack_config.json')
config = JSON.parse(config_file)
archive_uri = URI.parse(config["hipchat_archive_url"])
archive_filename = File.basename(archive_uri.path)
archive_dir_name = File.basename(archive_filename, ".tar.gz.aes")
export_root =    config["hipchat_archive_location"] + "/hipchat-export"



# Read in our rooms file
users_file = File.read(export_root + "/users.json")

# WHat do we want to call our new rooms file?
new_users_file = export_root + "/users.json"


# Read our rooms into an array
users = JSON.parse(users_file)

users.each do |user|

  begin   

  if user["User"]["is_deleted"]
    user["User"]["mention_name"] << "-deactivated"
    user["User"]["account_type"] = "guest"
  end
  
  if user["User"]["email"] == nil
    user["User"]["email"] = "admin-it+slack_migration@puppet.com"

 end


 if user["User"]["account_type"] == "guest"
   user["User"]["is_deleted"] = true
   user["User"]["mention_name"] << "-guest"

end

  rescue => e 
    puts e.inspect, index
  end



end

# Write our new rooms file, turning our room_list array back into JSON
File.write(new_users_file, JSON.pretty_generate(users))
