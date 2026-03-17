# Zeitwerk notes

This repo is a Rails engines gem, so `zeitwerk:check` is run from the dummy apps:

- `core/test/dummy`
- `admin/test/dummy`
- `storefront/test/dummy`

## Symptom

After upgrading to Rails 7 (Zeitwerk autoloader), constant loading failures surface as
`NameError: uninitialized constant` errors at runtime or during eager loading. Common
causes include `require_dependency` calls (deprecated in Zeitwerk mode), non-standard
autoload paths not registered with Zeitwerk, or file/class naming mismatches.

## Root cause

Rails 7 uses Zeitwerk as the default autoloader (replacing Classic mode). Zeitwerk
enforces strict file-to-constant naming conventions. Code that relied on
`require_dependency`, custom `autoload_paths` without Zeitwerk registration, or
mixed-namespace files may fail under Zeitwerk.

## Detection

```bash
# Run Zeitwerk check from each dummy app
cd core/test/dummy && bundle exec bin/rails zeitwerk:check
cd admin/test/dummy && bundle exec bin/rails zeitwerk:check
cd storefront/test/dummy && bundle exec bin/rails zeitwerk:check

# Verify production eager load
SECRET_KEY_BASE=dummy RAILS_ENV=production bundle exec bin/rails runner \
  'Rails.application.eager_load!; puts "Eager load OK"'

# Find any remaining require_dependency calls
grep -rn "require_dependency" core/ admin/ storefront/ --include="*.rb"
```

## Fix

1. Remove all `require_dependency` calls — Zeitwerk autoloads `app/` files automatically.
2. Register any custom `app/` subdirectories in the engine's `config.autoload_paths`.
3. Ensure file naming follows `namespace/class_name.rb` → `Namespace::ClassName` convention.
4. Verify `isolate_namespace` is set correctly in each engine.

See [Edge cases audited](#edge-cases-audited-wa-verify-047-2026-03-16) below for
specific Workarea findings.

---

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

---

## References / Links

- [Zeitwerk gem](https://github.com/fxn/zeitwerk)
- [Rails Guides: Autoloading with Zeitwerk](https://guides.rubyonrails.org/autoloading_and_reloading_constants.html)
- [Rails 7.0 Release Notes — Autoloading](https://edgeguides.rubyonrails.org/7_0_release_notes.html)
- [WA-VERIFY-047](https://github.com/workarea-commerce/workarea/issues) — Zeitwerk edge case audit
- [WA-VERIFY-058, issue #1023](https://github.com/workarea-commerce/workarea/issues/1023) — Zeitwerk check script in CI (closed/done)
