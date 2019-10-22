app = Rails.application
app.config.middleware.use(Mongoid::QueryCache::Middleware)
app.config.middleware.use(Workarea::Elasticsearch::QueryCache::Middleware)

if !app.config.action_dispatch.rack_cache
  app.config.middleware.use Dragonfly::Middleware, :workarea
else
  require 'rack/cache'
  app.config.middleware.insert_after Rack::Cache, Dragonfly::Middleware, :workarea
end

unless Rails.env.test? || Rails.env.development?
  app.config.middleware.insert 0, Rack::Timeout
  app.config.middleware.insert 1, Rack::Attack
end

# This serves sample files for imports
Rails.application.config.middleware.insert_after(
  Rack::Sendfile,
  ActionDispatch::Static,
  "#{Workarea::Admin.root}/public"
)

app.config.middleware.use Workarea::EnforceHostMiddleware
app.config.middleware.insert(0, Workarea::ApplicationMiddleware)
app.config.middleware.insert(0, Workarea::StripHttpCachingMiddleware) if Rails.env.test?
