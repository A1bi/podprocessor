# frozen_string_literal: true

require 'sinatra/base'
require 'sassc'
require 'uglifier'
require 'sprockets'
require 'bootstrap'

require './app'

map '/assets' do
  environment = Sprockets::Environment.new
  environment.append_path 'assets'
  environment.js_compressor  = :uglify
  environment.css_compressor = :sass
  run environment
end

map '/' do
  run PodProcessor.new
end
