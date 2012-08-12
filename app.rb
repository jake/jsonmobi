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
  if ['x.json.dev', 'x.json.mobi'].include? request.host then
    content_type :json
  elsif ['x.jsonp.dev', 'x.jsonp.mobi'].include? request.host then
    content_type :js
    @pad = true
  else
    erb :edit_index, :layout => :edit
  end
end

def error_resp(code = 404)
  response.status = code
  
  codes = {
    404 => {
      'message' => 'Not found'
    }
  }
  
  {
    'error' => {
      'code' => code.to_s,
      'message' => codes[code]['message']
    }
  }.to_json
end

def pad(json)
  'json_mobi(' + json + ')'
end

def grab(name)
  REDIS.get(name)
end

get '/:key?' do
  obj = params[:key] ? grab(params[:key]) : {'json' => 'yup'}.to_json
  obj = obj ? obj : error_resp(404)
  @pad ? pad(obj) : obj
end
