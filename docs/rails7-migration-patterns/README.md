# Rails 7 Migration Patterns

This directory contains **opinionated, field-tested patterns** for upgrading Workarea applications to Rails 7.

These documents are primarily for downstream Workarea client applications.

## Patterns

- **[Webpacker → Sprockets 4](./webpacker-to-sprockets-4.md)** (recommended default)
- **[Optional: jsbundling-rails (esbuild) + Sprockets](./jsbundling-rails-esbuild.md)** (for apps that need modern JS tooling)
- **[Sprockets 4 manifest.js format changes](./sprockets-manifest-format.md)** (fixing missing assets after Sprockets 4 upgrade)
- **[URL/routing helper behavior changes](./url-routing-helpers.md)** (default_url_options context changes)
- **[Assets pipeline / Webpacker removal](./assets-pipeline-webpacker-removal.md)** (Webpacker removal / Sprockets 4 / Propshaft migration)
- **[Mongoid 8 `any_of` semantics change](./mongoid8-any-of-semantics.md)** (array-arg vs splat + loop-chaining fix patterns)
