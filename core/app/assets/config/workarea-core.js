// Sprockets 4 engine manifest for workarea-core.
// Host apps should include this via:  //= link workarea-core
// in their own app/assets/config/manifest.js.
//
// Core provides shared utilities (workarea.js) and base images/SVGs.
// The workarea.js file is included by admin and storefront application
// manifests via require directives, so it does not need to be a
// standalone top-level target in most host apps.
//= link workarea/core/workarea.js
//= link_tree ../images
