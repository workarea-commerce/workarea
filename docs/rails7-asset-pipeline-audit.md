# Rails 7 Asset Pipeline Audit (WA-RAILS7-003)

## Summary

Workarea's asset pipeline uses Sprockets 3.7 with `sprockets-rails` 3.2. Rails 7 ships
with sprockets-rails 3.4+ which expects **Sprockets 4.x**. This document records the
audit findings and the changes made to unblock asset compilation on Rails 7.

---

## Changes Made

### 1. gemspec constraints widened (`core/workarea-core.gemspec`)

| Gem | Before | After | Reason |
|-----|--------|-------|--------|
| `sprockets` | `~> 3.7` | `>= 3.7, < 5` | Allow Sprockets 4.x which Rails 7 requires |
| `sprockets-rails` | `~> 3.2` | `>= 3.2, < 4` | Allow 3.4.x (latest) — latest is 3.5.2 |

### 2. Sprockets 4 API compatibility (`core/lib/workarea/ext/sprockets/ruby_processor.rb`)

The `.ruby` engine extension used `register_engine` with `silence_deprecation: true`,
which is valid in Sprockets 3.7 (the method existed but was deprecated). **Sprockets 4
removed `register_engine` entirely.**

The updated file uses version detection to call the correct API:
- **Sprockets 4+**: `register_mime_type` + `register_transformer` (new API)
- **Sprockets 3.7**: `register_engine` with `silence_deprecation: true` (legacy path)

### 3. Sprockets 4 engine manifests added

Sprockets 4 changes how top-level assets are discovered. Without a `manifest.js`,
Sprockets 4 uses its own discovery logic which can differ from Sprockets 3. Engine
manifests have been added for each engine:

- `core/app/assets/config/workarea-core.js`
- `admin/app/assets/config/workarea-admin.js`
- `storefront/app/assets/config/workarea-storefront.js`
- `core/test/dummy/app/assets/config/manifest.js`
- `storefront/test/dummy/app/assets/config/manifest.js`

**Host applications** using Sprockets 4 should add a `app/assets/config/manifest.js`:

```js
// app/assets/config/manifest.js
//= link_tree ../images
//= link application.css
//= link application.js
//= link workarea-admin
//= link workarea-storefront
```

---

## Gem Dependency Audit

### ✅ Compatible with Rails 7 (no changes needed)

| Gem | Current Constraint | Latest | Notes |
|-----|-------------------|--------|-------|
| `sassc-rails` | `~> 2.1` | 2.1.2 | Rails 7 compatible |
| `jquery-rails` | `~> 4.4` | 4.6.1 | Rails 7 compatible |
| `select2-rails` | `~> 4.0` | 4.0.13 | No active development; still works |
| `turbolinks` | `~> 5.2` | 5.2.1 | Rails 7 compatible (Turbo replaces it long-term) |
| `normalize-rails` | `~> 8.0` | 8.0.1 | Stable, no Rails dependency |
| `lodash-rails` | `~> 4.17` | 4.17.21 | Stable, no Rails dependency |
| `tooltipster-rails` | `~> 4.2` | 4.2.7 | Stable |
| `waypoints_rails` | `~> 4.0` | 4.0.1 | Stable |
| `featurejs_rails` | `~> 1.0` | 1.0.1.1 | Stable |
| `tribute` | `~> 3.6` | 3.7.x | Stable |
| `avalanche-rails` | `~> 1.2` | 1.2.x | Stable |
| `inline_svg` | `~> 1.7` | 1.10.0 | Rails 7 compatible |

### ⚠️ Review recommended

| Gem | Current | Notes |
|-----|---------|-------|
| `jquery-ui-rails` | `~> 6.0` (6.0.1) | Latest is 8.0.0. Version 7+ has API changes for custom widgets; upgrading requires testing. The `~> 6.0` constraint blocks this by design. Consider widening if testing confirms compatibility. |
| `jquery-livetype-rails` | `~> 0.1` | Unmaintained (last release 2015). Functionality may be reimplemented natively. Note in gemspec says "TODO remove v4". |
| `jquery-unique-clone-rails` | `~> 1.0` | Unmaintained (last release 2013). Small jQuery plugin; consider inlining or removing. |
| `js-routes` | `~> 1.4` | Latest is 2.x (breaking change). 1.4.x works with Rails 7 but js-routes 2.x is the Rails 7+ recommended version. Long-term, 1.4.x will likely be deprecated by the maintainer. |
| `autoprefixer-rails` | pinned `9.8.5` | Latest is 10.4.x. The pin is intentional (newer version emits deprecation warnings). No Rails 7 blocker here; upgrade when the warning is resolved. |
| `serviceworker-rails` | `~> 0.6` | Latest is 0.6.0; the gem has not been updated since 2019. Service Worker manifest generation should be verified for Rails 7 middleware stack compatibility. See issue #731 (rack-cache). |

### 🚫 Abandoned / unmaintained gems

| Gem | Last Release | Impact | Recommendation |
|-----|-------------|--------|---------------|
| `jquery-livetype-rails` | 2015 | Admin UI live typing for search | Remove in v4+ cleanup (already noted with TODO) |
| `jquery-unique-clone-rails` | 2013 | jQuery helper | Inline the small plugin or remove if unused |
| `wysihtml-rails` | ~2016 (pre-release) | WYSIWYG editor in admin | Long-term replacement target; still functional on Rails 7 |

---

## Sprockets 4 Migration Notes for Plugin Authors

If you maintain a Workarea plugin, add a Sprockets 4 engine manifest:

```
# your_plugin/app/assets/config/workarea-YOUR_PLUGIN.js
//= link workarea/your_plugin/application.js
//= link workarea/your_plugin/application.css
//= link_tree ../images
```

If your plugin uses `.ruby` extension files (`.jst.ejs.ruby`), the updated
`ruby_processor.rb` handles Sprockets 3 and 4 transparently — no changes needed
in plugin code.

---

## Testing

```sh
# Verify asset compilation (run in the test dummy app)
cd core && bundle exec rake assets:precompile RAILS_ENV=production
cd admin && bundle exec rake assets:precompile RAILS_ENV=production
cd storefront && bundle exec rake assets:precompile RAILS_ENV=production

# Run Teaspoon JS tests (from root, if configured)
bundle exec rake teaspoon
```

See [Rails Sprockets 4 Upgrade Guide](https://github.com/rails/sprockets/blob/main/UPGRADING.md)
for complete migration documentation.
