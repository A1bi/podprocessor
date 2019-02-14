# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/config_file'
require 'slim'

require './workers/processor'

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
    podcast = params[:podcast]
    return 422 unless podcast_exist? podcast

    original_filename = params[:file][:filename]
    audio_file = params[:file][:tempfile]

    digest = Digest::SHA256.file(audio_file)
    file_hash = digest.hexdigest[0..16]

    target_filename = filename_without_extension(original_filename)
    target_filename << "_#{file_hash}"
    target_filename.tr!(' ', '_')
    path = target_path(target_filename, podcast)

    unless File.exist? path
      File.open(path, 'wb') do |f|
        f.write(audio_file.read)
      end
    end

    Processor.perform_async(path, settings.processing)

    Pathname.new(podcast).join(filename_with_extension(target_filename)).to_s
  end

  delete '/files' do
    path = request.body.read
    podcast = File.dirname(path)
    return 422 unless podcast_exist? podcast

    filepath = target_path(filename_without_extension(path), podcast)
    return 404 unless File.exist? filepath

    # disallow deletion files older than three hours
    return 403 if File.mtime(filepath) < Time.now - 10_800

    FileUtils.rm filepath
  end

  not_found do
    'Unknown action.'
  end

  private

  def target_path(filename, podcast)
    path = Pathname.new(settings.audio_file_destination).join(podcast)
    FileUtils.mkdir(path) unless Dir.exist? path
    path.join(filename_with_extension(filename))
  end

  def filename_with_extension(filename)
    filename + '.mp3'
  end

  def filename_without_extension(filename)
    File.basename(filename, File.extname(filename))
  end

  def podcast_exist?(name)
    settings.podcasts.key? name
  end
end
