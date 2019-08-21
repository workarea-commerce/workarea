app = Rails.application

# Hide the serviceworker-rails generators since they don't work with our
# namespacing and we can override the files using the `workarea:override`
# generator
app.config.generators.hide_namespace('serviceworker')

# Configure serviceworker-rails
app.config.serviceworker.routes.draw do
  match '/pwa_cache.js' => 'workarea/storefront/serviceworkers/pwa_cache.js'
end

# Precompile the required assets
app.config.assets.precompile += %w(
  workarea/storefront/serviceworkers/pwa_cache.js
)
