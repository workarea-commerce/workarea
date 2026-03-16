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

### 3. `isolate_namespace Workarea`

**Status: ✅ Compatible.** All three engines (`Core`, `Admin`, `Storefront`) use `isolate_namespace Workarea`. This is fully supported by Zeitwerk for Rails engines. Files under `app/` are expected under the `Workarea` namespace, which is correct.

### 4. Decorator / extension pattern

**Status: ✅ No Zeitwerk conflicts found.** Workarea uses a module prepend / decoration pattern rather than file-based autoloading for extensions. Extension files are not expected to follow Zeitwerk naming conventions automatically — they are explicitly required by the engine initializer.

## Notes

- Dummy apps use Mongoid, so production environment config should not assume `config.active_record` is available.
- Middleware stack is frozen after initialization; middleware changes must be configured during boot (not in `after_initialize`).
- When adding new `app/` subdirectories to Workarea engines, add them to `config.autoload_paths` in the engine file and ensure file naming follows `namespace/class_name.rb` → `Namespace::ClassName` convention.
