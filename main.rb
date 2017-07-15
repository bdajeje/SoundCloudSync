#!/usr/bin/env ruby

require 'httparty'
require 'json'
require 'soundcloud'

trap("SIGINT") { throw :ctrl_c }

def safe_name(name)
  name.gsub('/', ' ')
      .gsub('|', ' ')
end

# Arguments validation
if ARGV.length < 1
  puts "Usage:"
  puts "  ruby main.rb save_folder"
  exit
end

# Arguments extraction
save_folder = ARGV.shift
save_folder = save_folder.chomp('/') if save_folder.end_with?('/')

# Read credentials from file (credentials.json)
credentials = JSON.parse(File.read('credentials.json'))
credential  = credentials['credential'];
user_name   = credentials['user_name'];

# Create a client object with your app credentials
client = Soundcloud.new(:client_id => credential)

# Find all user playlists
user_playlists = client.get('/playlists', :user_id => user_name)

# Go throw each playlist to download their tracks
catch :ctrl_c do
  file_path = ''
  begin
    user_playlists.each_with_index do |playlist, playlist_index|
      playlist_name = playlist[:title]
      tracks = playlist.tracks
      puts "------------| Playlist (#{playlist_index + 1}/#{user_playlists.size}) - '#{playlist_name}' / #{tracks.size} tracks |------------"
      puts

      playlist_destination = "#{save_folder}/#{safe_name(playlist_name)}"

      # Check if playlist directory exists, if not create it
      Dir.mkdir(playlist_destination) unless File.exists?(playlist_destination)

      tracks.each_with_index do |track, index|
        name = track.title
        puts "[Track - #{track.id}] #{name} (#{index + 1}/#{tracks.size})"

        file_path = "#{playlist_destination}/#{safe_name(name)}.mp3"
        if File.exists?( file_path )
          puts 'already exists'
          puts
          next
        end

        download_url = track.download_url
        if !download_url || download_url.empty?
          puts 'not available for download'
          puts
          next
        end

        puts "Downloading it..."
        puts
        File.open(file_path, "wb") do |f|
          f.write HTTParty.get("https://api.soundcloud.com/tracks/#{track.id}/download?client_id=#{credential}").parsed_response
        end
      end
    end
  rescue => detail
    puts "Exception: #{detail}"

    # Remove not finished download file
    puts "#{file_path} unfinised download, deleting file"
    File.delete(file_path)
  end
end
