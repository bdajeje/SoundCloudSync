#!/usr/bin/env ruby

require "httparty"
require 'soundcloud'

def safe_name(name)
  name.gsub('/', ' ')
end

# Arguments validation
if ARGV.length < 3
  puts "Usage:"
  puts "  ruby main.rb credential user_name save_folder"
  exit
end

# Arguments extraction
credential  = ARGV.shift
user_name   = ARGV.shift
save_folder = ARGV.shift
save_folder = save_folder.chomp if save_folder.end_with?('/')

# Create a client object with your app credentials
client = Soundcloud.new(:client_id => credential)

# Find all user playlists
user_playlists = client.get('/playlists', :user_id => user_name)

# Go throw each playlist to download their tracks
user_playlists.each do |playlist|
  playlist_name = playlist[:title]
  tracks = playlist.tracks
  puts "------------| Playlist - '#{playlist_name}' / #{tracks.size} tracks |------------"
  puts

  playlist_destination = "#{save_folder}/#{safe_name(playlist_name)}"

  # Check if playlist directory exists, if not create it
  Dir.mkdir(playlist_destination) unless File.exists?(playlist_destination)

  tracks.each do |track|
    name = track.title
    puts "Track - #{name}"

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
    File.open(file_path, "wb") do |f|
      f.write HTTParty.get("https://api.soundcloud.com/tracks/#{track.id}/download?client_id=#{credential}").parsed_response
    end
  end
end
