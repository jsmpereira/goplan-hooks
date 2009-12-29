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
require 'yaml'

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

  push = JSON.parse(params[:payload])
    
  message = push['commits'][0]['message']
  
  commit_url = push['commits'][0]['url']
  
  ticket_to_close = message.scan(%r{Closes #+[0-9]+})
  
  ticket_id = ticket_to_close.to_s.split("#")[1]
  
  ticket_response = options.access_token.get("/weebiz/api/tickets/get/#{ticket_id}.json")
  ticket = JSON.parse(ticket_response.body)
  
  close_ticket = options.access_token.put("/weebiz/api/tickets/update/#{ticket_id}.json", {'ticket[status]' => 2})
  
  comment_text = "Closed.\n\n #{commit_url}"
  	
  close_comment = options.access_token.put("/weebiz/api/comments/create", {:format => 'json', 'comment[commentable_type]' => 'ticket', 'comment[commentable_cid]' => ticket_id, 'comment[text]' => "#{comment_text}"})

end

get '/' do
    "Have your github webhook point here; bridge works automatically via POST"
end
