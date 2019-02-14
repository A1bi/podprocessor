Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://localhost/' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://localhost/' }
end
