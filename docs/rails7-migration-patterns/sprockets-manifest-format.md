# Sprockets 4 manifest.js Format Changes

## Symptom

After upgrading to Sprockets 4 (bundled with Rails 7), assets that were previously
served or precompiled stop working. Common symptoms include:

- `ActionView::Template::Error: Asset 'application.css' not found` in production
- `Sprockets::FileNotFound` during `assets:precompile`
- JavaScript or CSS files missing from the precompiled asset manifest
- Engines / plugins contributing assets that are no longer included

## Root cause

Sprockets 4 changed the default asset-inclusion strategy. In Sprockets 3, **all**
top-level files in `app/assets` were automatically compiled. In Sprockets 4 a
`manifest.js` file (or `manifest.css` for CSS-only pipelines) must **explicitly
declare** which files and trees to include.

Without a manifest, or with a manifest that uses Sprockets 3 directives that are
no longer valid (e.g. bare `//= require_tree .` without a corresponding link
directive), assets silently disappear from the output.

Key breaking changes:

| Sprockets 3 | Sprockets 4 |
|---|---|
| All files auto-linked | Only files listed in manifest are compiled |
| `//= require_tree .` in JS/CSS includes files | Requires `//= link_tree` in `manifest.js` to compile them |
| `config.assets.precompile += [...]` enough | `manifest.js` is the canonical list |

For Workarea engine plugins, each engine's `app/assets` subtree must be linked
from the host-app manifest (or from the engine's own `manifest.js`, picked up
transitively).

## Detection

```bash
# Check for missing manifest
ls app/assets/config/manifest.js

# Inspect what the manifest currently declares
cat app/assets/config/manifest.js

# See what Sprockets 4 would actually compile
bundle exec rake assets:precompile --dry-run 2>&1 | grep -E "Compiled|Error"

# List files Sprockets sees as logical paths (should include engine assets)
bundle exec rails runner "puts Sprockets::Railtie.build_environment(Rails.application).logical_paths.keys.sort"
```

A `manifest.js` that only contains `//= link_tree ../images` (the Rails 7 default
scaffold) will miss JavaScript and CSS entirely.

## Fix

Create or update `app/assets/config/manifest.js` to explicitly link all asset
trees you need compiled:

```js
//= link_tree ../images
//= link_tree ../fonts
//= link_asset application.css
//= link_asset application.js

// Workarea engine assets — link each plugin's trees
//= link_tree ../../vendor/assets/images
```

For Workarea specifically, engine assets are resolved through the Sprockets load
path. Confirm each active engine exposes a `manifest.js` of its own:

```bash
# Find engine asset config manifests
find $(bundle show --paths | head -20) -name "manifest.js" -path "*/assets/config/*" 2>/dev/null
```

If an engine lacks a `manifest.js`, add one to your host app that links its trees,
or monkey-patch the engine to add the file in an initializer:

```ruby
# config/initializers/sprockets_manifest_fix.rb
Rails.application.config.after_initialize do
  Rails.application.config.assets.paths.each do |path|
    # engines that declare JS/CSS without a manifest.js need explicit linking
  end
end
```

Additionally, audit `config/initializers/assets.rb` (or the assets block in
`config/application.rb`). In Sprockets 4 the `precompile` list is additive on
top of `manifest.js`; files listed there are compiled **in addition to** the
manifest, not instead of it:

```ruby
# config/initializers/assets.rb — still valid in Sprockets 4 for extras
Rails.application.config.assets.precompile += %w[
  admin.js
  admin.css
]
```

## References

- Issue: [#904](https://github.com/workarea-commerce/workarea/issues/904) (this doc)
- Related: [webpacker-to-sprockets-4.md](./webpacker-to-sprockets-4.md) — covers the Webpacker removal path and
  initial Sprockets 4 adoption. This document covers the **manifest.js format**
  specifically.
- [Sprockets 4 Upgrade Guide](https://github.com/rails/sprockets/blob/main/UPGRADING.md#guide-to-upgrading-from-sprockets-3x-to-4x)
- [Rails 7.0 Release Notes — Asset Pipeline](https://edgeguides.rubyonrails.org/7_0_release_notes.html)

## Lint Rule (pseudocode)

```
rule "sprockets-4-manifest-required" do
  # Trigger when Gemfile (or gemspec) pins sprockets >= 4.0
  # AND app/assets/config/manifest.js is absent or empty

  condition do
    sprockets_version = gemfile_lock_version("sprockets")
    next false unless sprockets_version >= Gem::Version.new("4.0")

    manifest = read_file("app/assets/config/manifest.js")
    manifest.nil? || manifest.strip.empty? ||
      !manifest.match?(%r{//=\s+link(_tree|_asset|\s)})
  end

  message do
    <<~MSG
      Sprockets 4 requires an explicit app/assets/config/manifest.js.
      Without it, no assets will be compiled.

      Minimum viable manifest.js:
        //= link_tree ../images
        //= link_asset application.css
        //= link_asset application.js

      See docs/rails7-migration-patterns/sprockets-manifest-format.md
    MSG
  end

  severity :error
end
```
