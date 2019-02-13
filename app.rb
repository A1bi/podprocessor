# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader' if development?

get '/' do
  'Hello world!'
end

not_found do
  'Unknown action.'
end
