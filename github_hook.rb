#!/usr/bin/env ruby
#
# GitHub Post-Receive hook handler to add comments, and update state in Pivotal Tracker
# Configure your Tracker API key, and Project ID in a config.yml file placed in the
# same directory as this app.
# When you make commits to Git/GitHub, and want a comment and optionally a state update
# made to Tracker, add the following syntax to your commit message:
#     
#     [Story#####]
# or
#     [Story##### state:finished]
#

require 'rubygems'
require 'oauth'
require 'sinatra'
require 'json'
require 'rest_client'
require 'yaml'
require 'pp'

# load up configuration from YAML file
configure do
  begin
    config = open(File.expand_path(File.dirname(__FILE__) + '/goplan.yml')) { |f| YAML.load(f) }
    
    CONSUMER_KEY = config[:consumer_key]
    CONSUMER_SECRET = config[:consumer_secret]
    COMPANY_ALIAS = config[:company_alias]
    ACCESS_TOKEN = config[:access_token]
    ACCESS_TOKEN_SECRET = config[:access_token_secret]

    @consumer = OAuth::Consumer.new(CONSUMER_KEY, CONSUMER_SECRET, { :site => "http://#{COMPANY_ALIAS}.goplanapp.com"})
    set :access_token, OAuth::AccessToken.new(@consumer, ACCESS_TOKEN, ACCESS_TOKEN_SECRET)
  rescue => e
    puts "Failed to startup: #{e.message}"
    puts "Unable to load credentials file goplan.yml. You need to run goplan-auth before deploying your app."
    exit(-1)
  end
end

# The handler for the GitHub post-receive hook
post '/' do

  push['commits'].each { |commit| process_commit(commit) }
  
end

get '/' do
    "Have your github webhook point here; bridge works automatically via POST"
end

  
helpers do
  def process_commit(commit)
    # get commit message
    message = commit['message']
    
    message.scan(%r{Closes #+[0-9]+}) do |ticket_to_close|
      
      ticket_id = ticket_to_close.to_s.split("#")[1]
      
      ticket_response = options.access_token.get("/weebiz/api/tickets/get/30.json")
      pp ticket = JSON.parse(ticket_response.body)

      options.access_token.put("/weebiz/api/tickets/update/30", {:cid => ticket[:cid], :status => 2})

    end

  end
end
