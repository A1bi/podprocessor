# frozen_string_literal: true

require 'rubygems'
require 'bundler'

Bundler.require(:default, ENV['RACK_ENV'])

Encoding.default_internal = Encoding::UTF_8
Encoding.default_external = Encoding::UTF_8

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
