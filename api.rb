require 'sinatra'

configure do
  require 'redis'
  uri = URI.parse(ENV["REDISTOGO_URL"])
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end

def error_resp(code)
  message = {
    500 => 'Error',
    403 => 'Forbidden',
    404 => 'Not found'
  }
  
  obj = {
    'error' => {
      'code' => code.to_s,
      'message' => message[code]
    }
  }.to_json
  
  @pad ? pad(obj) : obj
end

error 400..505 do
  error_resp(response.status)
end

before do
  @pad = false
  if ['x.jsonp.dev', 'x.jsonp.mobi'].include? request.host then
    content_type :js
    @pad = true
  else
    content_type :json
  end
end

def pad(json)
  'json_mobi(' + json + ')'
end

def grab(name)
  REDIS.get(name)
end

get '/:key?' do
  obj = params[:key] ? grab(params[:key]) : {'json' => 'yup'}.to_json
  
  if ! obj then halt 404 end
  
  @pad ? pad(obj) : obj
end
