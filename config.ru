# frozen_string_literal: true

require 'rubygems'
require 'bundler'
require 'sidekiq/web'

Bundler.require(:default, ENV['RACK_ENV'])

Encoding.default_internal = Encoding::UTF_8
Encoding.default_external = Encoding::UTF_8

if ENV['RACK_ENV'] == 'production'
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    Rack::Utils.secure_compare(
      ::Digest::SHA256.hexdigest(username),
      ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_WEB_USERNAME'] ||
                                 SecureRandom.hex)
    ) &&
      Rack::Utils.secure_compare(
        ::Digest::SHA256.hexdigest(password),
        ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_WEB_PASSWORD'] ||
                                   SecureRandom.hex)
      )
  end
end

require './app'

map '/assets' do
  environment = Sprockets::Environment.new
  environment.append_path 'assets'
  environment.js_compressor  = :uglify
  environment.css_compressor = :sassc
  run environment
end

map '/sidekiq' do
  run Sidekiq::Web
end

map '/' do
  run PodProcessor.new
end
