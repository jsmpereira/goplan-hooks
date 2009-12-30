require 'rubygems'
require 'oauth'
require 'sinatra'
require 'json'

configure do
  begin
    set :environment, :development
    config = YAML.load_file(File.join(File.dirname(__FILE__), 'config', 'goplan.yml'))
    
    CONSUMER_KEY = config[:consumer_key]
    CONSUMER_SECRET = config[:consumer_secret]
    COMPANY_ALIAS = config[:company_alias]
    ACCESS_TOKEN = config[:access_token]
    ACCESS_TOKEN_SECRET = config[:access_token_secret]
    
    @consumer = OAuth::Consumer.new(CONSUMER_KEY, CONSUMER_SECRET, { :site => "http://#{COMPANY_ALIAS}.goplanapp.com"})
    @access_token = OAuth::AccessToken.new(@consumer, ACCESS_TOKEN, ACCESS_TOKEN_SECRET)
  rescue => e
    puts "Failed to startup: #{e.message}"
    puts "Unable to load credentials file goplan.yml. You need to run goplan-auth before deploying your app."
    exit(-1)
  end
end

module GoPlan
  def service(name)
    Timeout.timeout(20) do
      post "/*/#{name}/" do
        payload = JSON.parse(params[:payload])
        project_alias = params['splat'][0]
        yield payload, project_alias
        halt
      end
      
      get "/*/#{name}/" do
        "hello"
      end
    end
  rescue Timeout::Error
  end
end
include GoPlan

Dir["#{File.dirname(__FILE__)}/services/**/*.rb"].each { |service| load service }