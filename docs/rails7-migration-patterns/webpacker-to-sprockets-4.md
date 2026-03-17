# Webpacker → Sprockets 4 (WA-RAILS7-019)

Rails 7 removed Webpacker from the default stack. Workarea's Rails 7 upgrade path uses
**Sprockets 4** (see the Sprockets 4 work that landed in PR #740).

This guide documents a practical migration path for **host applications** that historically
used Webpacker alongside Workarea.

---

## Symptom

After upgrading to Rails 7, asset compilation fails or JavaScript/CSS is missing at
runtime. Applications that relied on `javascript_pack_tag` / `stylesheet_pack_tag` see
errors such as:

```
Webpacker::Manifest::MissingEntryError: Webpacker can't find application.js
```

Or, if Webpacker is removed without a replacement:

```
ActionController::RoutingError: No route matches [GET] "/packs/js/application-abc123.js"
```

## Root cause

Rails 7 removed Webpacker as the default JavaScript bundler. Workarea's Rails 7 path
uses **Sprockets 4** instead. Host applications that previously mixed Webpacker with
Sprockets must migrate their JavaScript/CSS entrypoints and view helpers to
Sprockets-compatible equivalents.

## Detection

```bash
# Find Webpacker view helpers in layouts/views
grep -r "javascript_pack_tag\|stylesheet_pack_tag" app/ --include="*.erb" -l

# Check Gemfile for Webpacker gem
grep "webpacker" Gemfile

# Check for Webpacker config
ls config/webpacker.yml 2>/dev/null && echo "Webpacker config present"
```

---

## Summary / Recommendation

For most Workarea storefronts and admin customizations:

- Keep using the **asset pipeline (Sprockets 4)**
- Remove Webpacker
- Move your `app/javascript/packs/*` entrypoints into Sprockets-managed assets

If your application relies on modern JS bundling features (ESM, tree-shaking, TypeScript,
React/Vue build chains, etc.), see the optional guide:

- [`jsbundling-rails` (esbuild) + Sprockets](./jsbundling-rails-esbuild.md)

---

## Audit (core/admin/storefront)

As of this change, `core/`, `admin/`, and `storefront/` do **not** reference Webpacker.
Any remaining Webpacker references are limited to documentation and templates.

---

## Fix

### 1) Remove Webpacker from the host app

In your host application:

1. Remove the gem:

   ```ruby
   # Gemfile
   # gem 'webpacker'
   ```

2. Remove Webpacker config and bins (if present):

   ```
   config/webpacker.yml
   config/webpack/*
   bin/webpack
   bin/webpack-dev-server
   ```

3. Remove the pack output directory (common paths):

   ```
   public/packs
   public/packs-test
   ```

4. If you were using `javascript_pack_tag` / `stylesheet_pack_tag`, you'll replace those in a later step.

### 2) Ensure Sprockets 4 manifest exists

Sprockets 4 expects an explicit manifest file.

In the host application, add `app/assets/config/manifest.js` if it doesn't already exist:

```js
// app/assets/config/manifest.js
//= link_tree ../images
//= link application.css
//= link application.js

// Workarea engine entrypoints
//= link workarea-admin
//= link workarea-storefront
```

Notes:

- If your app has additional entrypoints, add them here (see step 4).
- Workarea engines provide their own manifests; the host manifest is still the place
  where you declare what the host app compiles.

### 3) Replace Webpacker tags in layouts/views

Replace pack helper tags with Sprockets tags.

Typical Webpacker usage:

```erb
<%= javascript_pack_tag 'application', 'data-turbo-track': 'reload' %>
<%= stylesheet_pack_tag 'application', 'data-turbo-track': 'reload' %>
```

Becomes:

```erb
<%= javascript_include_tag 'application', 'data-turbo-track': 'reload' %>
<%= stylesheet_link_tag 'application', 'data-turbo-track': 'reload' %>
```

If you referenced multiple packs, those typically become additional Sprockets entrypoints
(e.g. `checkout.js`, `account.js`, etc.) that you link via `javascript_include_tag`.

### 4) Move `packs/` entrypoints into Sprockets entrypoints

Webpacker conventionally uses `app/javascript/packs/*.js` as entry files.

For Sprockets, the conventional location is `app/assets/javascripts/`.

Example mapping:

- `app/javascript/packs/application.js` → `app/assets/javascripts/application.js`
- `app/javascript/packs/application.scss` → `app/assets/stylesheets/application.scss`

If you had multiple pack entrypoints, create corresponding Sprockets files:

- `app/javascript/packs/checkout.js` → `app/assets/javascripts/checkout.js`

And link them in `app/assets/config/manifest.js`:

```js
//= link checkout.js
```

### 5) Update import / require style

Sprockets does not handle ESM imports the same way Webpacker did.

Common changes:

- Replace `import ... from ...` (Webpacker) with Sprockets directives when using
  classic asset-pipeline libraries:

  ```js
  //= require jquery
  //= require workarea/storefront
  ```

- If you need modern `import` semantics (ESM, NPM packages, transpilation), strongly
  consider using `jsbundling-rails` (see the optional guide).

### 6) Add additional assets to precompile (if needed)

If you add new top-level assets that aren't linked in `manifest.js`, you may need to
add them to `config/initializers/assets.rb`:

```ruby
Rails.application.config.assets.precompile += %w[
  checkout.js
  checkout.css
]
```

Prefer the manifest approach in Sprockets 4 where possible.

### 7) Verify locally and in CI

- `bin/rails assets:clobber`
- `bin/rails assets:precompile`
- Boot the app and verify:
  - Storefront loads and behaves normally
  - Admin loads and behaves normally
  - No missing asset errors in logs

---

## Common pitfalls

- **Missing `manifest.js`**: Sprockets 4 will not behave like Sprockets 3 without it.
- **Assuming ESM works in Sprockets**: it generally won't; use a bundler if you need it.
- **Forgetting Workarea entrypoints**: ensure `workarea-admin` and `workarea-storefront`
  are linked (typically via the host manifest).

---

## References / Links

- Related PR: [#740](https://github.com/workarea-commerce/workarea/pull/740) (Sprockets 4 in Workarea)
- Optional guide: [jsbundling-rails (esbuild) + Sprockets](./jsbundling-rails-esbuild.md)
- [Sprockets 4 Upgrade Guide](https://github.com/rails/sprockets/blob/main/UPGRADING.md)
- [Rails 7.0 Release Notes — Asset Pipeline](https://edgeguides.rubyonrails.org/7_0_release_notes.html)
