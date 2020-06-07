# frozen_string_literal: true

require 'sinatra/config_file'
require 'sinatra/reloader'
require 'encrypted_cookie'

require './workers/processor'

class PodProcessor < Sinatra::Base
  register Sinatra::ConfigFile
  use Rack::Session::EncryptedCookie, secret: ENV['SESSION_SECRET']

  config_file 'config/config.yml'

  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    authenticate

    slim :index, locals: { podcasts: settings.podcasts, email: session[:email] }
  end

  post '/files' do
    authenticate

    podcast = params[:podcast]
    return 422 unless podcast_exist?(podcast) && params[:email] =~ /.+@.+\..+/

    original_filename = params[:file][:filename].force_encoding('utf-8')
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

    session[:email] = params[:email]

    Processor.perform_async(path, params[:email])

    Pathname.new(podcast).join(filename_with_extension(target_filename)).to_s
  end

  delete '/files' do
    authenticate

    path = request.body.read
    podcast = File.dirname(path)
    return 422 unless podcast_exist? podcast

    filepath = target_path(filename_without_extension(path), podcast)
    return 404 unless File.exist? filepath

    # disallow deletion files older than three hours
    return 403 if File.mtime(filepath) < Time.now - 10_800

    FileUtils.rm filepath
  end

  get '/login' do
    slim :login
  end

  post '/login' do
    if params[:password] == ENV['AUTH_PASSWORD']
      session[:authenticated_at] = session[:last_seen_at] = Time.now
      redirect '/'
    else
      slim :login, locals: { error: true }
    end
  end

  get '/logout' do
    destroy_authentication
    redirect '/login'
  end

  not_found do
    'Unknown action.'
  end

  private

  def authenticate
    unless authenticated? && recently_seen?
      destroy_authentication
      return redirect '/login'
    end

    session[:last_seen_at] = Time.now
  end

  def authenticated?
    !session[:authenticated_at].nil? &&
      session[:authenticated_at] > Time.now - 86_400
  end

  def recently_seen?
    !session[:last_seen_at].nil? && session[:last_seen_at] > Time.now - 10_080
  end

  def destroy_authentication
    session[:authenticated_at] = nil
  end

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
