Geocoder.configure(
  logger: Rails.logger,
  http_proxy: ENV['HTTP_PROXY'],
  https_proxy: ENV['HTTPS_PROXY']
)

if Workarea.redis && Rails.configuration.action_controller.perform_caching
  Geocoder.configure(
    cache: Workarea::AutoexpireCacheRedis.new(Workarea.redis)
  )
end

geocoder_config = Workarea::Configuration::AppSecrets[:geocoder]
if geocoder_config.present?
  Geocoder.configure(geocoder_config.merge(use_https: true))
end
