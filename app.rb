# frozen_string_literal: true

require 'sassc'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'slim'
require 'sprockets'
require 'uglifier'

class PodProcessor < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  set :environment, Sprockets::Environment.new

  environment.append_path 'assets'

  environment.js_compressor  = :uglify
  environment.css_compressor = :sass

  # get assets
  get '/assets/*' do
    env['PATH_INFO'].sub!('/assets', '')
    settings.environment.call(env)
  end

  get '/' do
    slim :index
  end

  not_found do
    'Unknown action.'
  end
end
