require 'sinatra'

configure do
  require 'redis'
  uri = URI.parse(ENV["REDISTOGO_URL"])
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end

error 400..505 do
  code = response.status
  
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
  }
  
  if @output_mode == 'web' then
    '<h1>Error</h1>' + obj['error']['message']
  else
    obj = obj.to_json
    @output_mode == 'jsonp' ? pad(obj) : obj
  end
end

before do
  if ['x.jsonp.dev', 'x.jsonp.mobi'].include? request.host then
    content_type :js
    @output_mode = 'jsonp'
  elsif ['x.json.dev', 'x.json.mobi'].include? request.host then
    content_type :json
    @output_mode = 'json'
  else
    @output_mode = 'web'
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
  
  if @output_mode == 'web' then
    '<h1>' + obj + '</h1>'
  else
    @output_mode == 'jsonp' ? pad(obj) : obj
  end
end
