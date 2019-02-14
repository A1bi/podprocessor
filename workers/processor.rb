require 'sidekiq'
require 'pathname'

class Processor
  include Sidekiq::Worker

  def perform(path, config)
    return unless File.exist?(path)

    basename = filename_without_extension(path)
    original = Pathname.new(File.dirname(path)).join("#{basename}_original#{File.extname(path)}")
    FileUtils.mv path, original

    config.each do |format, props|
      target_path = Pathname.new(File.dirname(path)).join(basename + ".#{format}")
      system("ffmpeg -i '#{original}' -ar #{props['sampling_rate']} -ab #{props['bitrate']} -f #{format} -y '#{target_path}'")
    end
  end

  private

  def filename_without_extension(filename)
    File.basename(filename, File.extname(filename))
  end
end
