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
    original_filename = params[:file][:filename]
    audio_file = params[:file][:tempfile]

    digest = Digest::SHA256.file(audio_file)
    file_hash = digest.hexdigest[0..16]

    target_filename = File.basename(original_filename, File.extname(original_filename))
    target_filename << "_#{file_hash}"
    target_filename.gsub!(' ', '_')

    File.open(target_path(target_filename), 'wb') do |f|
      f.write(audio_file.read)
    end

    target_filename
  end

  delete '/files' do
    path = target_path(File.basename(request.body.read))
    FileUtils.rm path if File.exist? path
  end

  not_found do
    'Unknown action.'
  end

  private

  def target_path(filename)
    Pathname.new(settings.audio_file_destination).join(filename + '.mp3')
  end
end
