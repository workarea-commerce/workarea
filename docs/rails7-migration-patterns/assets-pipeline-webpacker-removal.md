# Pattern: Assets Pipeline — Webpacker Removal / Sprockets 4 / Propshaft Migration

**Related issue:** workarea-commerce/workarea#904

---

## Symptom

After upgrading to Rails 7, JavaScript assets fail to compile or are missing at runtime. Common error messages include:

```
Webpacker::Manifest::MissingEntryError: Webpacker can't find application.js
```

or, when Webpacker is removed and no replacement is configured:

```
ActionController::RoutingError: No route matches [GET] "/packs/js/application-abc123.js"
```

CSS may also fail to load if `sass-rails` or `webpacker`-managed SCSS is not migrated to a supported pipeline.

---

## Root Cause

Rails 7 removed Webpacker as the default JavaScript bundler. The `webpacker` gem is no longer maintained by the Rails core team and does not support Rails 7+ without significant patching.

Rails 7 introduces three asset pipeline options:

1. **Sprockets 4** (CSS + legacy JS) — still supported, but JavaScript bundling via `sprockets` requires manual configuration of `importmap-rails`, `jsbundling-rails`, or `cssbundling-rails`.
2. **Propshaft** — a lightweight replacement for Sprockets focused on asset fingerprinting; does not transpile JS/CSS itself.
3. **Import Maps** (`importmap-rails`) — browser-native ES module imports; no bundler required but not compatible with all npm packages.

Workarea's storefront and admin both ship JavaScript and CSS that was historically managed through Sprockets. If the host app or a plugin added Webpacker configuration, that configuration becomes invalid in Rails 7.

---

## Detection

### Check for Webpacker references

```bash
grep -r "webpacker\|Webpacker" \
  config/ app/ Gemfile package.json \
  --include="*.rb" --include="*.yml" --include="*.json" \
  -l
```

### Check Gemfile for removed/incompatible gems

```bash
grep -E "webpacker|sass-rails" Gemfile
```

### Check for `config/webpacker.yml`

```bash
ls config/webpacker.yml 2>/dev/null && echo "Webpacker config present"
```

### Check JavaScript pack tags in views

```bash
grep -r "javascript_pack_tag\|stylesheet_pack_tag" app/ --include="*.erb" -l
```

Any hits on `javascript_pack_tag` or `stylesheet_pack_tag` indicate Webpacker-dependent view helpers that must be replaced.

---

## Fix

### Step 1 — Remove Webpacker

In `Gemfile`:

```ruby
# Remove:
gem "webpacker"

# Add your chosen pipeline, e.g.:
gem "sprockets-rails"          # Sprockets 4 (already a Rails dep)
# OR
gem "propshaft"                # Propshaft (lightweight, no transpile)
# OR
gem "jsbundling-rails"         # esbuild / rollup / webpack via jsbundling
gem "cssbundling-rails"        # PostCSS / Sass via cssbundling
```

### Step 2 — Replace Webpacker view helpers

| Webpacker helper | Sprockets / importmap replacement |
|---|---|
| `javascript_pack_tag "application"` | `javascript_include_tag "application"` |
| `stylesheet_pack_tag "application"` | `stylesheet_link_tag "application"` |

### Step 3 — Migrate asset manifests

**Sprockets 4** requires an explicit manifest file. Create `app/assets/config/manifest.js`:

```js
//= link_tree ../images
//= link_directory ../stylesheets .css
//= link application.js
```

Without this, Sprockets 4 will not compile assets not explicitly linked.

### Step 4 — Update `config/application.rb`

Ensure the asset pipeline is configured:

```ruby
# For Sprockets (default):
config.assets.enabled = true

# Remove any Webpacker-specific config:
# config.webpacker.check_yarn_integrity = false  # DELETE THIS
```

### Step 5 — Delete Webpacker artifacts

```bash
rm -f config/webpacker.yml
rm -rf app/javascript/packs     # if migrating away from webpack entry points
```

If staying with a webpack-based setup, migrate to `jsbundling-rails` which provides a `rails assets:precompile`-compatible interface.

### Step 6 — Test

```bash
bin/rails assets:precompile RAILS_ENV=production
```

Verify no `MissingEntryError` or missing manifest errors appear.

---

## Workarea PR / Issue

- **Issue:** [workarea-commerce/workarea#904](https://github.com/workarea-commerce/workarea/issues/904)

If your application uses Workarea plugins that ship their own Webpacker configurations (e.g., custom packs under `app/javascript/packs`), each plugin's assets must be audited separately. Check with plugin maintainers for Rails 7–compatible releases.

---

## Lint Rule (Pseudocode)

The following pseudocode describes an automated rule to flag Webpacker usage in a Rails 7+ project:

```
rule "WA-ASSET-001: Webpacker usage detected in Rails 7+ project" do
  severity: :error
  trigger:  rails_version >= 7

  check Gemfile do
    flag if gem("webpacker") present
  end

  check "config/webpacker.yml" do
    flag if file exists
  end

  check views("**/*.erb", "**/*.haml") do
    flag if contains("javascript_pack_tag") or contains("stylesheet_pack_tag")
  end

  check "config/application.rb", "config/environments/*.rb" do
    flag if contains("config.webpacker")
  end

  message: |
    Webpacker is not supported in Rails 7. Replace with one of:
      - sprockets-rails + importmap-rails (no bundler)
      - jsbundling-rails (esbuild/rollup/webpack)
      - propshaft + cssbundling-rails
    See: docs/rails7-migration-patterns/assets-pipeline-webpacker-removal.md
end
```

---

## See Also

- [Rails 7.0 Release Notes — Asset Pipeline](https://edgeguides.rubyonrails.org/7_0_release_notes.html)
- [importmap-rails](https://github.com/rails/importmap-rails)
- [jsbundling-rails](https://github.com/rails/jsbundling-rails)
- [cssbundling-rails](https://github.com/rails/cssbundling-rails)
- [Propshaft](https://github.com/rails/propshaft)
- [Sprockets 4 upgrade guide](https://github.com/rails/sprockets/blob/main/UPGRADING.md)
