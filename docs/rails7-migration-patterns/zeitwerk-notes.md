# Zeitwerk notes

This repo is a Rails engines gem, so `zeitwerk:check` is run from the dummy apps:

- `core/test/dummy`
- `admin/test/dummy`
- `storefront/test/dummy`

## Results (2026-03-04)

- `bundle exec bin/rails zeitwerk:check` ✅ (all three dummy apps)
- Production eager load ✅
  - Command used:
    - `SECRET_KEY_BASE=dummy RAILS_ENV=production bundle exec bin/rails runner 'Rails.application.eager_load!; puts "Eager load OK"'`

## Edge cases audited (WA-VERIFY-047, 2026-03-16)

### 1. `require_dependency` (deprecated in Zeitwerk mode)

**Status: ✅ Resolved.** Three files previously used `require_dependency`; these have been removed and replaced with comments documenting the Zeitwerk behavior:

- `core/app/models/workarea/release/changeset.rb`
- `core/app/models/workarea/content.rb`
- `core/app/models/workarea/search/storefront/category_query.rb`

The comments read: `# require_dependency removed: Zeitwerk autoloads app/ files`

### 2. Custom `autoload_paths` in engines

**Status: ✅ Compatible.** `Workarea::Core::Engine` adds non-standard paths:

```ruby
%w(app/queries app/seeds app/services app/view_models app/workers).each do |path|
  config.autoload_paths << "#{root}/#{path}"
end
```

Zeitwerk supports custom paths added via `config.autoload_paths`. These paths follow standard naming conventions (e.g., `app/view_models/workarea/foo/bar_view_model.rb` maps to `Workarea::Foo::BarViewModel`). No edge case here.

### 3. `isolate_namespace` — per-engine namespaces

**Status: ✅ Compatible.** Each engine uses a distinct namespace:

- `Workarea::Core::Engine` → `isolate_namespace Workarea`
- `Workarea::Admin::Engine` → `isolate_namespace Workarea::Admin`
- `Workarea::Storefront::Engine` → `isolate_namespace Workarea::Storefront`

All three are fully supported by Zeitwerk for Rails engines. Files under each engine's `app/` directory must be placed under the corresponding namespace (`Workarea`, `Workarea::Admin`, or `Workarea::Storefront` respectively).

### 4. Decorator / extension pattern

**Status: ✅ No Zeitwerk conflicts found in the decoration pattern itself.** Workarea uses a module prepend / decoration pattern rather than file-based autoloading for extensions. Extension files are not expected to follow Zeitwerk naming conventions automatically — they are explicitly required by the engine initializer.

### 5. Known open Zeitwerk autoload workarounds

**Status: ⚠️ Open — requires future investigation.** Two files in `core/lib/workarea/core/engine.rb` are explicitly `require`-d inside `config.to_prepare` because Zeitwerk fails to autoload them:

```ruby
config.to_prepare do
  # For some reason, app/workers/workarea/bulk_index_products.rb doesn't
  # get autoloaded. Without this, admin actions like updating product
  # attributes raises a {NameError} "uninitialized constant BulkIndexProducts".
  require 'workarea/bulk_index_products'

  # Fixes a constant error raised in middleware (when doing segmentation)
  # No idea what the cause is. TODO revisit after Zeitwerk.
  require 'workarea/metrics/user'
end
```

These are **not resolved**. The `# TODO revisit after Zeitwerk` comment confirms these are known workarounds for unexplained autoload failures. Until root-caused and fixed, any `zeitwerk:check` green result does not mean full Zeitwerk autoloading is working for these two constants — they are loaded via explicit `require` fallback.

Potential investigation paths:
- Verify file naming convention matches expected constant path (`workarea/bulk_index_products.rb` → `Workarea::BulkIndexProducts`)
- Check for inflector irregularities (e.g., `BulkIndexProducts` vs `BulkIndexProduct`)
- Confirm the files are within a Zeitwerk-managed path, not a manually-required path

## Notes

- Dummy apps use Mongoid, so production environment config should not assume `config.active_record` is available.
- Middleware stack is frozen after initialization; middleware changes must be configured during boot (not in `after_initialize`).
- When adding new `app/` subdirectories to Workarea engines, add them to **both** `config.autoload_paths` and `config.eager_load_paths` in the engine file (see `core/lib/workarea/plugin.rb` for the pattern), and ensure file naming follows `namespace/class_name.rb` → `Namespace::ClassName` convention.
