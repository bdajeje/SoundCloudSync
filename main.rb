require "httparty"
require 'soundcloud'

require_relative 'credentials'
require_relative 'logger'

# \todo replace with input args
credentials_filepath = 'credentials'
user_name = 'bdajeje'
save_folder = '/home/jeje/Desktop/soundcloud' # No '/' at the end

# Logger
logger = Logger.new(:all)

# Create a client object with your app credentials
credentials = Credentials.new(credentials_filepath)
client = Soundcloud.new(:client_id => credentials.client_id)

# Find all user playlists
user_playlists = client.get('/playlists', :user_id => user_name)

# Go throw each playlist to download their tracks
user_playlists.each do |playlist|
  playlist_name = playlist[:title]
  tracks = playlist.tracks
  logger.log(:info, "Playlist - '#{playlist_name}' / #{tracks.size} tracks")

  playlist_destination = "#{save_folder}/#{playlist_name.gsub('/', ' ')}/"

  tracks.each do |track|
    name = track.title
    logger.log(:info, "Track - #{name}")

    if File.exists?( "#{playlist_destination}/#{name}" )
      logger.log(:info, 'already exists')
      next
    end

    download_url = track.download_url
    if !download_url || download_url.empty?
      logger.log(:info, 'not available for download')
      next
    end

    puts track.methods.sort
    puts track.type
    sdf

    # logger.log(:info, "Downloading it...")
    # File.open("#{save_folder}/#{name}.mp3", "wb") do |f|
    #   f.write HTTParty.get("https://api.soundcloud.com/tracks/159842862/download?client_id=#{credentials.client_id}").parsed_response
    # end
  end
end
