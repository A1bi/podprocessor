# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/reloader'
require 'slim'

class PodProcessor < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    slim :index
  end

  not_found do
    'Unknown action.'
  end
end
