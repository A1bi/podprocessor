# frozen_string_literal: true

require 'sidekiq'
require 'erb'
require 'pathname'
require 'pony'

require_relative '../app'
require_relative '../config/pony'

class Processor
  include Sidekiq::Worker

  def perform(path)
    return unless File.exist?(path)

    original, basename = move_original(path)
    success = false

    PodProcessor.settings.processing.each do |format, props|
      target_path = Pathname.new(File.dirname(path)).join(basename + ".#{format}")
      success = transcode(original, props['sampling_rate'], props['bitrate'], format, target_path)
      break unless success
    end

    mail(basename) if success
  end

  private

  def move_original(path)
    basename = filename_without_extension(path)
    original = Pathname.new(File.dirname(path)).join("#{basename}_original#{File.extname(path)}")
    FileUtils.mv path, original
    [original, basename]
  end

  def transcode(original, sampling_rate, bitrate, format, target_path)
    system("ffmpeg -i '#{original}' \
                   -ar #{sampling_rate} \
                   -ab #{bitrate} -f #{format} \
                   -y '#{target_path}'")
  end

  def mail(slug)
    Pony.mail to: PodProcessor.settings.mail['recipient'],
              from: PodProcessor.settings.mail['sender'],
              subject: PodProcessor.settings.mail['subject'],
              body: render('email', slug: slug)
  end

  def render(template, locals = {})
    ERB.new(File.read("./views/#{template}.erb")).result_with_hash(locals)
  end

  def filename_without_extension(filename)
    File.basename(filename, File.extname(filename))
  end
end
