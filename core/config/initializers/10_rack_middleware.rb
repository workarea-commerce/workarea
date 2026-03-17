# Rails 7.2+ runs setup_main_autoloader (Zeitwerk) AFTER load_config_initializers,
# so constants from app/ directories are not yet autoloadable when this file runs.
# Explicitly require the Workarea middleware classes used below.
require "#{File.expand_path('../../../app/middleware/workarea/enforce_host_middleware', __FILE__)}"
require "#{File.expand_path('../../../app/middleware/workarea/application_middleware', __FILE__)}"
require "#{File.expand_path('../../../app/middleware/workarea/strip_http_caching_middleware', __FILE__)}"

app = Rails.application

# Mongoid query cache middleware — clears per-request Mongoid query cache.
# Mongoid 8+ delegates Mongoid::QueryCache::Middleware to Mongo::QueryCache::Middleware.
app.config.middleware.use(Mongoid::QueryCache::Middleware)
app.config.middleware.use(Workarea::Elasticsearch::QueryCache::Middleware)

# Rack::Cache was removed from Rails 7.1.  On Rails < 7.1 it may be present
# when action_dispatch.rack_cache is configured; on 7.1+ HTTP caching is
# handled natively by ActionDispatch (stale?/fresh_when/expires_in).
rack_cache_enabled = app.config.action_dispatch.rack_cache &&
  (Rails::VERSION::MAJOR < 7 || (Rails::VERSION::MAJOR == 7 && Rails::VERSION::MINOR < 1))

if rack_cache_enabled
  require 'rack/cache'

  # Insert Dragonfly after Rack::Cache so Dragonfly-served assets bypass the
  # cache correctly.
  #
  # NOTE: Middleware stacks are frozen after initialization, so we must
  # configure this during boot (not in an `after_initialize` hook).
  app.config.middleware.delete(Rack::Cache)
  app.config.middleware.use(Rack::Cache)
  app.config.middleware.insert_after Rack::Cache, Dragonfly::Middleware, :workarea
else
  # On Rails >= 7.1 or when Rack::Cache is not configured, append Dragonfly
  # at the end of the stack.
  app.config.middleware.use Dragonfly::Middleware, :workarea
end

# Rack::Timeout and Rack::Attack are inserted at the outermost positions so
# they wrap the entire request cycle.  Excluded from test/development to
# avoid masking slow tests and to simplify local request debugging.
#
# rack-attack >= 6.2 ships a Railtie that auto-inserts Rack::Attack into the
# middleware stack for Rails 5.1+ applications.  On those versions the
# middleware may already be present by the time this initializer runs.  We
# delete it first (a no-op when absent) so that the explicit insert 1 always
# lands Rack::Attack at the correct outermost position without creating a
# duplicate entry.  This is also safe when rack-attack is upgraded to 6.7+,
# which adds Rack 3 / Rails 7 compatibility.
unless Rails.env.test? || Rails.env.development?
  app.config.middleware.insert 0, Rack::Timeout
  app.config.middleware.delete(Rack::Attack)
  app.config.middleware.insert 1, Rack::Attack
end

# Serve static sample files used by the admin data-file import UI.
# Rack::Sendfile is always present in the Rails default middleware stack.
Rails.application.config.middleware.insert_after(
  Rack::Sendfile,
  ActionDispatch::Static,
  "#{Workarea::Admin.root}/public"
)

app.config.middleware.use Workarea::EnforceHostMiddleware

# ApplicationMiddleware must wrap the entire Workarea request pipeline so it
# can set up the Workarea::Visit, locale, and cache-key env vars before any
# controller or caching layer runs.
app.config.middleware.insert(0, Workarea::ApplicationMiddleware)

# In test environments, strip all HTTP caching headers from responses so that
# headless-browser tests behave consistently regardless of cache state.
app.config.middleware.insert(0, Workarea::StripHttpCachingMiddleware) if Rails.env.test?
