# Optional: jsbundling-rails (esbuild) + Sprockets (WA-RAILS7-019)

Some Workarea host applications used Webpacker because they needed modern JS tooling:

- ES modules (`import`/`export`)
- npm packages
- TypeScript
- React/Vue/Svelte toolchains
- tree-shaking / minification / code splitting

For those applications, a pragmatic Rails 7 path is:

- **Sprockets 4** for Workarea engine assets + images/fonts + (optionally) CSS
- **jsbundling-rails + esbuild** for application-specific JavaScript bundling

This keeps the Workarea engines on the asset pipeline while giving the host app a modern
bundler.

---

## High-level approach

1. Add `jsbundling-rails` and choose `esbuild`.
2. Output the built bundle(s) into `app/assets/builds`.
3. Have Sprockets serve those compiled outputs by linking `app/assets/builds` in the
   Sprockets manifest.

---

## Setup steps (host application)

### 1) Add the gem

```ruby
# Gemfile
gem 'jsbundling-rails'
```

Then:

```bash
bundle install
```

### 2) Install jsbundling-rails for esbuild

```bash
bin/rails javascript:install:esbuild
```

This typically:

- adds `esbuild` to `package.json`
- adds build scripts
- creates `app/javascript/application.js`
- configures output into `app/assets/builds`

### 3) Link builds in the Sprockets manifest

Ensure your host app has `app/assets/config/manifest.js` and that it links the builds
directory:

```js
// app/assets/config/manifest.js
//= link_tree ../images
//= link_tree ../builds

//= link application.css

// Workarea engine entrypoints
//= link workarea-admin
//= link workarea-storefront
```

### 4) Use Sprockets tags that point at the built output

When using jsbundling-rails, you typically include the compiled output (which Sprockets
now knows about via `link_tree ../builds`).

```erb
<%= javascript_include_tag 'application', 'data-turbo-track': 'reload' %>
```

Note: depending on the installer and your scripts, the compiled file may be named
`application.js` (served from `app/assets/builds/application.js`).

### 5) Ensure build runs in CI / production

In production deploys, you need both:

- `yarn build` (or `npm run build`)
- `bin/rails assets:precompile`

Many Rails deployments wire this automatically, but if your pipeline previously relied
on Webpacker’s compilation step, you may need to add a build step explicitly.

---

## Troubleshooting

### Symptom: `The asset "application.js" is not present in the asset pipeline`

**Detection**: This usually appears during `assets:precompile` or when rendering a
layout that calls `javascript_include_tag 'application'`.

**Fix**:

1. Ensure `app/assets/config/manifest.js` links the builds directory:

   ```js
   //= link_tree ../builds
   ```

2. Ensure the JS build runs *before* `assets:precompile` in CI / production:

   ```bash
   yarn build
   bin/rails assets:precompile
   ```

### Symptom: JS changes don’t show up in development

**Fix**: Use `bin/dev` (or otherwise run the esbuild watch process) so changes get
rebuilt into `app/assets/builds`.

---

## Notes for Workarea apps

- Workarea’s admin/storefront JS is still Sprockets-managed.
- Your host app’s custom JS can be bundled and delivered via `app/assets/builds`.
- Workarea itself has **no hard dependency on Webpacker** (no `javascript_pack_tag`,
  `Webpacker` constants, etc.). Webpacker references should be limited to docs/migration
  guides.
- If you also want modern CSS tooling, consider `cssbundling-rails` similarly, but keep
  the surface area small during the Rails 7 upgrade.

---

## When *not* to use this

If your JS customizations are relatively small and don’t require npm/transpilation,
prefer the simpler **Sprockets-only** approach:

- [`Webpacker → Sprockets 4`](./webpacker-to-sprockets-4.md)
