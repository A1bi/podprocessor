# frozen_string_literal: true

require 'sidekiq'
require 'erb'
require 'pathname'
require 'pony'

require_relative '../app'
require_relative '../config/sidekiq'
require_relative '../config/pony'

Encoding.default_internal = Encoding::UTF_8
Encoding.default_external = Encoding::UTF_8

class Processor
  include Sidekiq::Worker

  def perform(path, recipient)
    return unless File.exist?(path)

    original, basename = move_original(path)
    success = false

    PodProcessor.settings.processing.each do |format, props|
      target_path = base_path(path).join(basename + ".#{format}")
      success = transcode(original, props['sampling_rate'], props['bitrate'],
                          format, target_path)
      break unless success
    end

    mail(basename, recipient, success)
  end

  private

  def move_original(path)
    basename = filename_without_extension(path)
    original = base_path(path).join("#{basename}_original#{File.extname(path)}")
    FileUtils.mv path, original
    [original, basename]
  end

  def transcode(original, sampling_rate, bitrate, format, target_path)
    system("ffmpeg -i '#{original}' \
                   -ar #{sampling_rate} \
                   -ab #{bitrate} -f #{format} \
                   -y '#{target_path}'")
  end

  def mail(slug, recipient, success)
    Pony.mail to: recipient,
              from: PodProcessor.settings.mail['sender'],
              subject: email_subject(success),
              body: render("email_#{result_suffix(success)}", slug:)
  end

  def email_subject(success)
    PodProcessor.settings.mail["subject_#{result_suffix(success)}"]
  end

  def render(template, locals = {})
    ERB.new(File.read("./views/#{template}.erb")).result_with_hash(locals)
  end

  def base_path(path)
    Pathname.new(File.dirname(path))
  end

  def filename_without_extension(filename)
    File.basename(filename, File.extname(filename))
  end

  def result_suffix(success)
    success ? :success : :error
  end
end
