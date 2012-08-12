require 'sinatra/base'

class WebApp < Sinatra::Base
  # configure do
  #   require 'redis'
  #   uri = URI.parse(ENV["REDISTOGO_URL"])
  #   REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  # end
  # 
  # def grab(name)
  #   REDIS.get(name)
  # end

  get '/' do
    'web app'
  end
  
  # get '/asdf' do
  #   'web asdf'
  # end
end