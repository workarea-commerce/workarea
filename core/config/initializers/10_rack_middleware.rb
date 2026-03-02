app = Rails.application

# Mongoid query cache middleware — clears per-request Mongoid query cache.
# Mongoid::QueryCache::Middleware exists in Mongoid 7.x (pinned via gemspec).
app.config.middleware.use(Mongoid::QueryCache::Middleware)
app.config.middleware.use(Workarea::Elasticsearch::QueryCache::Middleware)

# Rack::Cache was removed from Rails 7.1.  On Rails < 7.1 it may be present
# when action_dispatch.rack_cache is configured; on 7.1+ HTTP caching is
# handled natively by ActionDispatch (stale?/fresh_when/expires_in).
rack_cache_enabled = app.config.action_dispatch.rack_cache &&
  (Rails::VERSION::MAJOR < 7 || (Rails::VERSION::MAJOR == 7 && Rails::VERSION::MINOR < 1))

if rack_cache_enabled
  require 'rack/cache'

  # Insert Dragonfly after Rack::Cache so Dragonfly-served assets bypass
  # the cache correctly.  We defer to after_initialize so we can verify
  # Rack::Cache is actually present in the finalized middleware stack
  # (it may not be if the app removed it explicitly after configuration).
  app.config.after_initialize do |initialized_app|
    if initialized_app.middleware.include?(Rack::Cache)
      initialized_app.middleware.insert_after Rack::Cache, Dragonfly::Middleware, :workarea
    else
      initialized_app.middleware.use Dragonfly::Middleware, :workarea
    end
  end
else
  # On Rails >= 7.1 or when Rack::Cache is not configured, append Dragonfly
  # at the end of the stack.
  app.config.middleware.use Dragonfly::Middleware, :workarea
end

# Rack::Timeout and Rack::Attack are inserted at the outermost positions so
# they wrap the entire request cycle.  Excluded from test/development to
# avoid masking slow tests and to simplify local request debugging.
unless Rails.env.test? || Rails.env.development?
  app.config.middleware.insert 0, Rack::Timeout
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
