require 'sinatra/base'
require 'sinatra/subdomain'

class BaseApp < Sinatra::Base
  register Sinatra::Subdomain
  
  subdomain :x do
    get '/' do 'api!' end
  end
  
  subdomain :www do
    get '/' do 'www!' end
  end
end
