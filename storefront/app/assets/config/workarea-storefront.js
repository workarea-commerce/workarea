// Sprockets 4 engine manifest for workarea-storefront.
// Host apps should include this via:  //= link workarea-storefront
// in their own app/assets/config/manifest.js.
//
// This declares the top-level targets that Sprockets 4 should compile
// from the storefront engine. Additional standalone assets (email CSS,
// images, SVGs) are registered via config.assets.precompile in
// core/config/initializers/02_assets.rb.
//= link workarea/storefront/application.js
//= link workarea/storefront/application.css
//= link_tree ../images
//= link_tree ../fonts
