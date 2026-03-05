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

## Notes for Workarea apps

- Workarea’s admin/storefront JS is still Sprockets-managed.
- Your host app’s custom JS can be bundled and delivered via `app/assets/builds`.
- If you also want modern CSS tooling, consider `cssbundling-rails` similarly, but keep
  the surface area small during the Rails 7 upgrade.

---

## When *not* to use this

If your JS customizations are relatively small and don’t require npm/transpilation,
prefer the simpler **Sprockets-only** approach:

- [`Webpacker → Sprockets 4`](./webpacker-to-sprockets-4.md)
