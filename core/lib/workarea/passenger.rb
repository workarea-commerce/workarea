PhusionPassenger.on_event(:starting_worker_process) do |forked|
  Sidekiq.configure_client do |config|
    config.redis = { url: Workarea::Configuration::Redis.persistent.to_url }
  end
end
