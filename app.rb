require 'sinatra'
require 'erb'
#require 'sinatra/basic_auth'
#require 'json'

configure do
  require 'redis'
  uri = URI.parse(ENV["REDISTOGO_URL"])
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end

before do
  @pad = false
  if ['json.dev', 'json.mobi'].include? request.host then
    content_type 'application/json'
  elsif ['jsonp.dev', 'jsonp.mobi'].include? request.host then
    content_type 'application/javascript'
    @pad = true
  elsif ['edit.json.dev', 'edit.jsonp.dev', 'edit.json.mobi', 'edit.json.mobi'].include? request.host then
    erb :edit_index, :layout => :edit
  end
end

def pad(obj)
  (params[:callback] ? params[:callback] : "json_mobi") + "(" + obj + ");"
end

get '/:key' do
  if @pad then pad(params[:key])
  else params[:key] end
end

get '/' do
  if @pad then pad("{json:'yup'}")
  else "{json:'yup'}" end
end
