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

if Rails.application.secrets.geocoder.present?
  Geocoder.configure(Rails.application.secrets.geocoder.merge(use_https: true))
end
