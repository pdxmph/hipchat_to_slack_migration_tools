#!/usr/bin/env ruby 

require 'json'
require 'google_drive'
require 'haml'

config_file  = File.read('slack_config.json')
config = JSON.parse(config_file)
archive_uri = URI.parse(config["hipchat_archive_url"])
archive_filename = File.basename(archive_uri.path)
archive_dir_name = File.basename(archive_filename, ".tar.gz.aes")
export_root =    config["hipchat_archive_location"] + "/#{archive_dir_name}"

# Read in our rooms file
rooms_file = File.read(export_root + "/rooms.json")


# At some point this becomes a rake task that takes an argument, for now we're hardcoding
#room_id = ARGV[0]
room_id = "109437"

room_file = File.read("#{export_root}/rooms/#{room_id}/history.json")

messages = JSON.parse(room_file)

# At some point, we'll dump every message, for now just the first 10 to test formatting
messages[0..10].each do |message|



  begin
    next if message["NotificationMessage"] || message["TopicRoomMessage"]
    message_text = message["UserMessage"]["message"]
    message_timestamp = message["UserMessage"]["timestamp"]
    user_name = message["UserMessage"]["sender"]["name"]


# Our template uses bootstrap classes 

@mess_tmp = <<-MESSAGE
<div class="panel panel-default">
<div class="panel-heading">
 <h4 class="panel-title">#{message_timestamp} -- #{user_name}</h4>
</div>
<div class="panel-body"
  <pre>
    #{message_text}
  </pre>
  </div>
</div>
MESSAGE


puts @mess_tmp

# puts "<div style='padding:.5em; margin:1em;border:1px solid #ccc;'><code>[#{message_timestamp}]</code>  <strong>#{user_name}:</strong> <pre>#{message_text}</pre> </div>"
  rescue => e
    puts e.inspect
    puts "========================================="
    puts "PARSE ERROR: RAW MESSAGE: "
    puts message.inspect
    puts "========================================="
  end

end
