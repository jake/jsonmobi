require 'sinatra'
require 'rufus/mnemo'

configure do
  require 'redis'
  uri = URI.parse(ENV["REDISTOGO_URL"])
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end

error 400..505 do
  code = response.status
  
  message = {
    400 => 'Bad Request',
    401 => 'Unauthorized',
    402 => 'Payment Required',
    403 => 'Forbidden',
    404 => 'Not Found',
    405 => 'Method Not Allowed',
    406 => 'Not Acceptable',
    407 => 'Proxy Authentication Required',
    408 => 'Request Timeout',
    409 => 'Conflict',
    410 => 'Gone',
    411 => 'Length Required',
    412 => 'Precondition Failed',
    413 => 'Request Entity Too Large',
    414 => 'Request-URI Too Long',
    415 => 'Unsupported Media Type',
    416 => 'Requested Range Not Satisfiable',
    417 => 'Expectation Failed',
    418 => 'I\'m a teapot',
    429 => 'Too Many Requests',
    
    500 => 'Internal Server Error',
    501 => 'Not Implemented',
    502 => 'Bad Gateway',
    503 => 'Service Unavailable',
    504 => 'Gateway Timeout',
    505 => 'HTTP Version Not Supported'
  }
  
  code = 418 if ! message[code]
  
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

post '/:key' do
  halt 400 if @output_mode != 'web'
  
  REDIS.set(params[:key], params[:json])
  
  redirect to('/' + params[:key])
end

get '/:key?' do
  @obj = grab(params[:key]) if params[:key]
  
  if @output_mode == 'web' then
    redirect to('/' + Rufus::Mnemo::to_s(rand 8**5)) if ! params[:key]
    
    @fresh_obj = ! @obj
    @obj ||= '{}'
    erb :edit
  else
    if ! params[:key] then
      @obj = {'json' => 'yup'}.to_json
    elsif ! @obj then
      halt 404
    end
    
    @output_mode == 'jsonp' ? pad(@obj) : @obj
  end
end
