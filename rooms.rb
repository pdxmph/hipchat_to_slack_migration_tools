#!/usr/bin/env ruby

require "google_drive"
require "json"

config_file  = File.read('slack_config.json')
config = JSON.parse(config_file)
archive_uri = URI.parse(config["hipchat_archive_url"])
archive_filename = File.basename(archive_uri.path)
archive_dir_name = File.basename(archive_filename, ".tar.gz.aes")
export_root =    config["hipchat_archive_location"] + "/#{archive_dir_name}"

# Read in our rooms file
rooms_file = File.read(export_root + "/rooms.json")

# WHat do we want to call our new rooms file?
new_rooms_file = export_root + "/rooms.json"

# Make an array where we can stuff room records we want to keep
room_list = []

# Read our rooms into an array
rooms = JSON.parse(rooms_file)

# Set up our session with Google Drive to read the master spreadsheet 
# You can figure out how to auth here:
# https://github.com/gimite/google-drive-ruby/blob/master/doc/authorization.md
session = GoogleDrive::Session.from_service_account_key("google_key.json")
ws = session.spreadsheet_by_key(config["google_spreadsheet_id"]).worksheets[0]

# Walk the spreadsheet
ws.rows.each_with_index do |row,index|
  
  begin 

  # skip the first row
  next if index == 0
  # skip any rows where the fifth column is empty
  next if row[4] == "" 
  next if row[4] == "-"

  # set a few variables for easier reference
  old_name = row[3]
  room_id = row[4]
  new_name = row[8]
  
  # where does the history file live? 
  room_history_path = "#{export_root}/rooms/#{room_id}/history.json"

  # Find the room by id in our array of rooms
  room_record = rooms.select { |k,v| k["Room"]["id"].to_i == room_id.to_i }.first

  # rename our room
  room_record["Room"]["name"] = new_name
  
  # change our room's topic to note what it used to be called
  unless room_record["Room"]["topic"]
    room_record["Room"]["topic"] = "(Former Room Name: #{old_name})"
  else
    room_record["Room"]["topic"]  << " (Former Room Name: #{old_name})"
  end
  
  # make some decisions depending on how we're handling the room
  case row[6]
  when "no"
    puts "Value: #{row[5]}: We are deleting this room's history, and we renamed it to #{new_name}"
    # overwrite the history.json file with an empty array
    File.write(room_history_path, '[]')
    
  when "html_transcript"
    puts "Value: #{row[5]}: We need to make a transcript and we renamed it to #{new_name}"
    # overwrite the history.json file with an empty array    
    File.write(room_history_path, '[]')
    
  when "slack_import" || "slack_import_extended"
    puts "Value: #{row[5]}: We need to save this room's content, and we renamed it to #{new_name}"
    # leave this room's content alone
  end

rescue => e 
  puts e.inspect, index
end

# tack that room record into the array we're going to write to disk 
room_list << room_record

end

# Write our new rooms file, turning our room_list array back into JSON
File.write(new_rooms_file, JSON.pretty_generate(room_list))
