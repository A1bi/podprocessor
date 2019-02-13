# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/config_file'
require 'slim'

class PodProcessor < Sinatra::Base
  register Sinatra::ConfigFile
  config_file 'config/config.yml'

  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    slim :index, locals: { podcasts: settings.podcasts }
  end

  post '/files' do
    'good'
  end

  delete '/files' do
    'good'
  end

  not_found do
    'Unknown action.'
  end
end
