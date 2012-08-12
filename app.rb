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

def error_resp(code = 404)
  '{"error":{"code":' + code.to_s + '}}'
end

def pad(obj)
  # (params[:callback] ? params[:callback] : "json_mobi") + "(" + obj + ");"
  'json_mobi(' + obj.to_s + ')'
end

def grab(name)
  REDIS.get(name)
end

get '/:key' do
  obj = grab(params[:key])
  obj = obj ? obj : error_resp(404)
  @pad ? pad(obj) : obj
end

get '/' do
  obj = '{"json":"yup"}'
  @pad ? pad(obj) : obj
end
