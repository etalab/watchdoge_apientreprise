Sidekiq.configure_server do |config|
  config.redis = { url: Rails.configuration.redis_database }
end

Sidekiq.configure_client do |config|
  config.redis = { url: Rails.configuration.redis_database }
end
