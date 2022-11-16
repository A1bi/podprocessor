# frozen_string_literal: true

redis = { path: '/var/run/redis/redis.sock' }

Sidekiq.configure_server do |config|
  config.redis = redis
end

Sidekiq.configure_client do |config|
  config.redis = redis
end
