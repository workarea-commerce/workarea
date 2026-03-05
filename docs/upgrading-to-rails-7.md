# Upgrading a Workarea Application to Rails 7

This guide is the single authoritative walkthrough for upgrading a Workarea client
application from Rails 6.1 to Rails 7.0. Follow the sections in order. The
[quick checklist](#quick-checklist) at the top gives you a bird's-eye view; each
step links to the detailed section below.

**Target:** Rails 7.0.x + Mongoid 8.1.x  
**Minimum Ruby:** 2.7 (Ruby 3.0+ recommended)  
**Workarea branch:** `next`

---

## Quick Checklist

Use this as a tracking list during your upgrade. Check off each item as you complete it.

### Environment
- [ ] Ruby ≥ 2.7 (3.0+ recommended) — see [Ruby Version](#ruby-version)
- [ ] Bundler ≥ 2.2
- [ ] Node.js ≥ 14, Yarn 1.x (classic)

### Gemfile Changes (Required)
- [ ] Rails: `~> 6.1` → `~> 7.0`
- [ ] Mongoid: `~> 7.4` → `~> 8.1`
- [ ] Sprockets: `~> 3.7` → `~> 4.0`; add `sprockets-rails ~> 3.4`
- [ ] Remove `rack-cache` (or guard behind `Rails < 7.1`)
- [ ] Selenium: `~> 4.9` (for Ruby 2.7 compatibility)
- [ ] Sidekiq: `~> 7.0` (if not already)
- [ ] Run `bundle update rails workarea mongoid`

### Configuration Changes (Required)
- [ ] Migrate `config/secrets.yml` → Rails credentials
- [ ] Update `config.load_defaults` to `7.0`
- [ ] Remove `config.autoloader = :classic` if present
- [ ] Add `config.hosts` entries for dev/test
- [ ] Remove or guard `rack-cache` middleware config in `production.rb`
- [ ] Update `mongoid.yml`: add `load_defaults: '7.5'`; remove deprecated options
- [ ] Recreate MongoDB indexes (`rails db:mongoid:create_indexes`)

### Code Changes (Required)
- [ ] Replace all `update_attributes` → `update`, `update_attributes!` → `update!`
- [ ] Replace all `require_dependency` calls (delete or replace with `require`)
- [ ] Replace `date.to_s(:format)` → `date.to_formatted_s(:format)` or `strftime`
- [ ] Replace `Rails.application.secrets.*` → `Rails.application.credentials.*`
- [ ] Update `ActiveSupport::Deprecation` usages (Rails 7.1 API change)
- [ ] Run `bin/rails zeitwerk:check` — fix any constant/file naming mismatches
- [ ] Audit custom `embedded_in` associations for explicit `touch:` option

### Asset Pipeline (Required if using Sprockets)
- [ ] Create `app/assets/config/manifest.js` with correct link directives
- [ ] Verify `bin/rails assets:precompile` succeeds

### Testing Changes (Required)
- [ ] Update Capybara driver: `driven_by :selenium, using: :headless_chrome`
- [ ] Replace `@request.host =` with `host!` in controller tests
- [ ] Update `webmock ~> 3.14`, `vcr ~> 6.1` if used

### Validation
- [ ] `bin/rails zeitwerk:check` — clean
- [ ] `bin/rails test` — full suite passes
- [ ] `bin/rails test:system` — system tests pass
- [ ] Smoke test: checkout, admin UI, search
- [ ] No remaining `DEPRECATION WARNING` in development logs

---

## Background

Workarea's `next` branch targets Rails 7.0 and Mongoid 8.1. A series of modernization
PRs have been merged to `next` that make the Workarea platform itself Rails 7-compatible.
Your upgrade has two parts:

1. **Pull in the updated Workarea gem** (which is already compatible on `next`)
2. **Update your own application code** (this guide covers that)

This guide focuses on what *client application* engineers need to do — not what was
already fixed inside Workarea core.

---

## Step 1: Prerequisites

### Ruby Version

Rails 7 requires Ruby 2.7 or later. Ruby 3.0+ is strongly recommended.

```bash
ruby -v
# Acceptable: ruby 2.7.x
# Recommended: ruby 3.0.x or later
```

To upgrade with rbenv:

```bash
rbenv install 3.2.7
rbenv local 3.2.7
echo '3.2.7' > .ruby-version
```

### Node.js and Yarn

Workarea continues to use the Sprockets asset pipeline. Ensure:

- Node.js ≥ 14.x
- Yarn 1.x (classic — not Yarn 2+)

```bash
node -v
yarn -v
```

### Bundler

```bash
gem install bundler
bundler -v   # Should be >= 2.2
```

---

## Step 2: Gemfile Changes

### Rails

```ruby
# Before
gem 'rails', '~> 6.1'

# After
gem 'rails', '~> 7.0'
```

### Mongoid

Mongoid 7.x is **not compatible with Rails 7**. Mongoid 8.1 is the minimum required version.

```ruby
# Before
gem 'mongoid', '~> 7.4'

# After
gem 'mongoid', '~> 8.1'
```

See [Step 6: Mongoid 8 Migration](#step-6-mongoid-8-migration) for the full details
and required code changes.

### Sprockets 4

```ruby
# Before
gem 'sprockets', '~> 3.7'
gem 'sprockets-rails', '~> 3.2'

# After
gem 'sprockets', '~> 4.0'
gem 'sprockets-rails', '>= 3.4'
```

See [Step 7: Asset Pipeline](#step-7-asset-pipeline) for asset manifest changes.

### Remove `rack-cache`

`rack-cache` is not compatible with Rails 7.1+ and is no longer required for
production HTTP caching. Remove it from your Gemfile.

```diff
-gem 'rack-cache'
```

Also remove any `config.action_dispatch.rack_cache` configuration from
`config/environments/production.rb`.

> **Note:** Workarea core guards its own `rack-cache` usage behind a
> `Rails < 7.1` check (merged in WA-RAILS7-002). Your application Gemfile
> should simply remove the gem.

### Selenium (for system tests)

Pin to `~> 4.9.0` for Ruby 2.7 compatibility:

```ruby
gem 'selenium-webdriver', '~> 4.9'
```

If you are on Ruby 3.0+, you can use `>= 4.0`.

### Full Gemfile diff

```diff
-gem 'rails', '~> 6.1'
+gem 'rails', '~> 7.0'

-gem 'mongoid', '~> 7.4'
+gem 'mongoid', '~> 8.1'

-gem 'sprockets', '~> 3.7'
-gem 'sprockets-rails', '~> 3.2'
+gem 'sprockets', '~> 4.0'
+gem 'sprockets-rails', '>= 3.4'

-gem 'rack-cache'

-gem 'selenium-webdriver', '~> 4.0'
+gem 'selenium-webdriver', '~> 4.9'
```

After editing, run:

```bash
bundle update rails workarea mongoid sprockets sprockets-rails
```

---

## Step 3: Configuration Changes

### Upgrade `config.load_defaults`

```ruby
# config/application.rb
# Before
config.load_defaults 6.1

# After
config.load_defaults 7.0
```

Review each changed default in the [Rails upgrading guide](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#new-framework-defaults).
Each new default can be set explicitly to the old value during testing, then removed
once verified.

### Remove Classic Autoloader

Rails 7 only supports Zeitwerk. Remove any classic autoloader config:

```ruby
# config/application.rb — remove this line if present
config.autoloader = :classic
```

### Host Authorization

Rails 7 enables host authorization middleware by default:

```ruby
# config/environments/development.rb
config.hosts << 'your-app.dev'
config.hosts << /.*\.ngrok\.io/  # if you use ngrok

# config/environments/test.rb
config.hosts = nil   # disable for test environment
```

### Remove rack-cache Middleware

```diff
# config/environments/production.rb
-config.action_dispatch.rack_cache = {
-  metastore: "#{Rails.root}/tmp/dragonfly/cache/meta",
-  entitystore: "#{Rails.root}/tmp/dragonfly/cache/body"
-}
```

### Migrate Secrets to Credentials

Rails 7 removes support for `config/secrets.yml`. Migrate to Rails credentials.

```bash
# Edit master credentials
EDITOR="nano" bin/rails credentials:edit

# Or per-environment (recommended for production)
EDITOR="nano" bin/rails credentials:edit --environment production
```

Replace all `Rails.application.secrets.*` calls:

```ruby
# Before
Rails.application.secrets.payment_gateway_key

# After
Rails.application.credentials.payment_gateway_key
```

Search for remaining usages:

```bash
grep -rn "\.secrets\." app/ config/ lib/
```

Delete `config/secrets.yml` once migrated.

> **Reference:** WA-RAILS7-006 (merged to `next`) covers the Workarea core
> credentials migration. Your application secrets need to be migrated separately.

---

## Step 4: Code Changes

### `update_attributes` → `update`

`update_attributes` was removed in Rails 7 (following its deprecation in Rails 6.1).

```ruby
# Before
record.update_attributes(name: 'Foo')
record.update_attributes!(name: 'Foo')

# After
record.update(name: 'Foo')
record.update!(name: 'Foo')
```

Find all occurrences in your application:

```bash
grep -rn "update_attributes" app/ lib/ --include="*.rb"
```

> **Note:** Workarea core replaced all 148 internal occurrences in WA-NEW-009
> and WA-NEW-015. Your application plugins and overrides need the same treatment.

### `require_dependency` Removed

Zeitwerk handles autoloading automatically. Delete all `require_dependency` calls:

```ruby
# Before
require_dependency 'workarea/foo'
require_dependency 'my_module/bar'

# After — delete the line entirely
# Use plain `require` only for files outside the autoload paths
```

```bash
grep -rn "require_dependency" app/ lib/ --include="*.rb"
```

> **Reference:** WA-RAILS7-007 (merged to `next`) removed all `require_dependency`
> calls from Workarea core.

### `to_s(:format)` → `to_formatted_s` or `strftime`

`Date#to_s` and `Time#to_s` no longer accept format symbols in Rails 7.

```ruby
# Before
date.to_s(:long)
time.to_s(:short)
date.to_s(:db)

# After
date.to_formatted_s(:long)
time.to_formatted_s(:short)
date.to_formatted_s(:db)
# or
date.strftime('%B %d, %Y')
```

Find all occurrences:

```bash
grep -rn '\.to_s(:[a-z]' app/ lib/ --include="*.rb"
```

### Zeitwerk: File Naming Conventions

Rails 7 requires strict file-to-constant name mapping. Check for violations:

```bash
bin/rails zeitwerk:check
```

Common fixes:
- File `app/models/my_module/foo_bar.rb` must define `MyModule::FooBar`
- Acronyms need explicit configuration in `config/initializers/inflections.rb`

```ruby
# config/initializers/inflections.rb
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym 'API'
  inflect.acronym 'CSV'
end
```

### `ActiveSupport::Deprecation` Changes (Rails 7.1)

Rails 7.1 deprecated the default `ActiveSupport::Deprecation` singleton. If your
application or plugins use it directly, update accordingly:

```ruby
# Before (Rails 6.x / 7.0)
ActiveSupport::Deprecation.warn("...")
ActiveSupport::Deprecation.silence { ... }

# After (Rails 7.1+)
# Option 1: Create a named deprecator
APP_DEPRECATOR = ActiveSupport::Deprecation.new('2.0', 'MyApp')
APP_DEPRECATOR.warn("...")

# Option 2: Use the app's deprecator (Rails 7.1+)
Rails.application.deprecators[:my_feature].warn("...")
```

> **Reference:** WA-RAILS7-008 (merged to `next`) updated Workarea core. Apply the
> same pattern in any custom deprecation calls in your application.

### Mailer Layouts

Rails 7 changed how mailer layouts are applied. If you have custom mailers with
broken layouts, declare them explicitly:

```ruby
class MyMailer < ApplicationMailer
  layout 'mailer'
end
```

Check view helpers in mailers — they should be defined as `helper_method` or
extracted to a shared helper module.

> **Reference:** WA-RAILS7-012 (merged to `next`) fixed ActionMailer compatibility
> in Workarea core. WA-NEW-039 cleaned up `ApplicationMailer` helper shims.

### Routing Changes

Rails 7 tightened URL helper behavior. If you see `NoMethodError` for URL helpers
in non-controller contexts, check that `default_url_options` is set:

```ruby
# config/environments/production.rb
config.action_mailer.default_url_options = { host: 'example.com', protocol: 'https' }
```

> **Reference:** WA-RAILS7-013 (merged to `next`) fixed routing and URL helper
> compatibility in Workarea core.

### Cookie / Session Serialization

Rails 7 defaults to JSON cookie serialization. If your app stores non-JSON-safe
objects in the session, you may see deserialization errors.

Ensure session values are JSON-serializable (strings, numbers, arrays, hashes):

```ruby
# Safe
session[:user_id] = current_user.id.to_s

# Unsafe (Marshal serialized — will break)
session[:cart] = MyCart.new(...)
```

> **Reference:** WA-RAILS7-011 (merged to `next`) fixed cookie and session storage
> for JSON safety across Workarea.

### Sidekiq 7

If you use Sidekiq, ensure you are on version 7.x:

```ruby
gem 'sidekiq', '~> 7.0'
```

Sidekiq 7 changed the job format and some middleware APIs. Review the
[Sidekiq upgrade guide](https://github.com/sidekiq/sidekiq/blob/main/docs/7.0-Upgrade.md).

> **Reference:** WA-RAILS7-005 (merged to `next`) fixed Sidekiq 7 incompatibilities
> in Workarea core.

### Rack::Attack (Middleware Ordering)

If your application uses `Rack::Attack`, Rails 7 / Rack 3 changed middleware
ordering behavior. Ensure `Rack::Attack` is explicitly inserted:

```ruby
# config/application.rb
config.middleware.use Rack::Attack
```

> **Reference:** WA-NEW-040 (merged to `next`) fixed Rack::Attack compatibility
> and added middleware stack ordering tests.

---

## Step 5: Zeitwerk Autoloader Verification

Run this before and after all code changes:

```bash
bin/rails zeitwerk:check
```

A clean output looks like:

```
Hold on, I am eager loading the application.
All is good!
```

Common violation patterns and fixes:

| Violation | Fix |
|-----------|-----|
| `expected file ... to define constant ...` | Rename file or fix class/module name |
| `NameError: uninitialized constant Foo::Bar` | Add proper namespace or check file location |
| Acronym mismatches (`Api` vs `API`) | Configure `ActiveSupport::Inflector.inflections` |

---

## Step 6: Mongoid 8 Migration

This is the most involved part of the upgrade. Mongoid 8.1 is required for Rails 7
support. See [`docs/research/mongoid-upgrade-path.md`](research/mongoid-upgrade-path.md)
for the full technical research.

### gemspec / Gemfile

```ruby
gem 'mongoid', '~> 8.1'
```

### Update `config/mongoid.yml`

Add `load_defaults` to preserve Mongoid 7.x behavior during the initial upgrade,
then migrate incrementally:

```yaml
# config/mongoid.yml
development:
  clients:
    default:
      uri: <%= ENV['MONGODB_URI'] || 'mongodb://localhost:27017/myapp_development' %>
  options:
    load_defaults: '7.5'      # Preserve Mongoid 7 behavior initially
    belongs_to_required_by_default: false
```

Remove deprecated options:

```yaml
# Remove these if present:
# identity_map_enabled
# allow_dynamic_fields (moved to model level)
```

### Recreate Indexes

After upgrading Mongoid, recreate all indexes:

```bash
rails db:mongoid:create_indexes
```

### Breaking Change: `update_attributes` Removed

Already covered in [Step 4](#update_attributes--update) — Mongoid 8 also removes
`update_attributes`. The grep and replace in that step covers both Rails and Mongoid.

### Breaking Change: Embedded Document Touch Behavior

Mongoid 8 changed the default `touch:` behavior for `embedded_in` associations:

| Version | Default |
|---------|---------|
| Mongoid 7.x | `touch: false` — embedded doc saves do NOT cascade `updated_at` to parent |
| Mongoid 8.x | `touch: true` — embedded doc saves DO cascade `updated_at` to parent |

This is a **silent breaking change** that can cause unexpected cache invalidation
and additional write operations.

**Workarea core** already added explicit `touch: false` declarations to all 40
embedded associations (WA-NEW-038). If you have custom plugins or extensions with
`embedded_in` associations, audit them:

```bash
grep -rn "embedded_in" app/models/ --include="*.rb" | grep -v "touch:"
```

Any line without an explicit `touch:` option will silently change behavior in
Mongoid 8. Fix by adding `touch: false` to preserve the Mongoid 7 behavior:

```ruby
# Before (implicit in Mongoid 7, changes behavior in Mongoid 8)
embedded_in :order

# After (explicit, same behavior in both)
embedded_in :order, touch: false
```

See [`docs/mongoid-8-embedded-document-migration.md`](../mongoid-8-embedded-document-migration.md)
for the full audit methodology and rationale for each association.

### Breaking Change: Recursive Save in `after_save`

Mongoid 8 prevents calling `save` inside `after_save` callbacks, which could recurse
indefinitely:

```ruby
# Before — will raise an error in Mongoid 8
after_save { save }

# After — use atomic Mongoid update that skips callbacks
after_save { set(computed_field: computed_value) }
```

`set` writes directly to MongoDB and bypasses validations and callbacks.

### Breaking Change: QueryCache API

`Mongoid::QueryCache` was deprecated in Mongoid 8 and removed in Mongoid 9.
Workarea core already handles this internally. If your application uses it directly:

```ruby
# Mongoid 7 (deprecated in 8, removed in 9)
Mongoid::QueryCache.clear_cache
Mongoid::QueryCache.uncached { ... }

# Mongoid 8+ / Mongoid 9 replacement
Mongo::QueryCache.clear
Mongo::QueryCache.uncached { ... }
```

---

## Step 7: Asset Pipeline

Sprockets 4 changes how top-level assets are discovered. Without a `manifest.js`,
Sprockets 4 uses its own discovery logic which may differ from Sprockets 3.

See [`docs/rails7-asset-pipeline-audit.md`](../rails7-asset-pipeline-audit.md) for
the full audit of changes made to Workarea core.

### Add `app/assets/config/manifest.js`

Create this file if it doesn't exist:

```js
// app/assets/config/manifest.js
//= link_tree ../images
//= link application.css
//= link application.js
//= link workarea-admin
//= link workarea-storefront
```

Link only the top-level files you need. Do not use `link_tree` for CSS/JS — use
`link_directory` instead:

```js
//= link_tree ../images
//= link_directory ../stylesheets .css
//= link_directory ../javascripts .js
```

### Verify Precompilation

```bash
bin/rails assets:precompile RAILS_ENV=production
```

Fix any `ActionView::Template::Error` or `Sprockets::FileNotFound` errors by
checking that your manifest correctly links all required files.

### Plugin Authors

If you maintain a Workarea plugin, add a Sprockets 4 engine manifest:

```js
// your_plugin/app/assets/config/workarea-your-plugin.js
//= link workarea/your_plugin/application.js
//= link workarea/your_plugin/application.css
//= link_tree ../images
```

---

## Step 8: Testing Changes

### System Tests

```ruby
# test/application_system_test_case.rb
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
end
```

### Controller Test Host

```ruby
# Before
@request.host = 'example.com'

# After
host! 'example.com'
```

### HTTP Dependency Gems

Update for Ruby 3 Net::HTTP compatibility:

```ruby
gem 'webmock', '>= 3.14'
gem 'vcr', '>= 6.1'
```

---

## Step 9: Final Verification

Run through this checklist before declaring the upgrade complete:

```bash
# 1. Zeitwerk naming — must be clean
bin/rails zeitwerk:check

# 2. Full test suite
bin/rails test

# 3. System tests
bin/rails test:system

# 4. Asset precompilation
bin/rails assets:precompile RAILS_ENV=production

# 5. Check for lingering deprecation warnings
bin/rails server 2>&1 | grep DEPRECATION

# 6. Verify indexes are current
bin/rails db:mongoid:create_indexes
```

Manually smoke-test these flows:
- Storefront: browse → add to cart → checkout
- Admin: log in, browse products, orders, content
- Search: keyword search and faceted filtering

---

## HAML Compatibility Note

Workarea uses HAML 5.2.2, which is fully compatible with Rails 7. **No HAML changes
are required.** Workarea confirmed HAML 5.2 satisfies Rails 7's two-arity template
handler requirement.

HAML 6 is deferred — the migration would have HIGH client impact and is not part of
this upgrade. Do not upgrade to HAML 6 as part of the Rails 7 migration.

See [`docs/research/haml-rails7-compat.md`](research/haml-rails7-compat.md) for the
full compatibility investigation.

---

## Known Issues

### `NameError: uninitialized constant` After Upgrade

**Cause:** Zeitwerk requires strict file-to-constant naming.

**Fix:**

```bash
bin/rails zeitwerk:check
```

Rename files so `app/models/my_module/foo_bar.rb` defines `MyModule::FooBar`.

---

### Asset Precompilation Failures

**Cause:** Sprockets 4 requires explicit manifest declarations.

**Fix:** Ensure `app/assets/config/manifest.js` exists and links all required assets.
See [Step 7: Asset Pipeline](#step-7-asset-pipeline).

---

### `ActionView::Template::Error` with `to_s` format

**Cause:** `Date#to_s(:format)` removed in Rails 7.

**Fix:** Replace with `to_formatted_s` or `strftime`. See [Step 4: Code Changes](#step-4-code-changes).

---

### Mongoid Embedded Touch Cascade

**Cause:** Mongoid 8 changed `embedded_in` default from `touch: false` to `touch: true`.

**Symptom:** Parent document `updated_at` changes unexpectedly; caches invalidate more
frequently than before.

**Fix:** Add explicit `touch: false` to all `embedded_in` associations in your custom
models. See [Step 6: Mongoid 8 Migration](#step-6-mongoid-8-migration).

---

### Mongoid Recursive Save Error

**Cause:** Mongoid 8 prevents `save` inside `after_save` callbacks.

**Fix:** Use `set(field: value)` for atomic updates inside callbacks.

---

### `Rack::Attack` Not Blocking Requests

**Cause:** Rails 7 / Rack 3 changed middleware ordering.

**Fix:** Ensure `Rack::Attack` is explicitly inserted in `config/application.rb`:

```ruby
config.middleware.use Rack::Attack
```

---

## Reference Documents

| Document | Topic |
|----------|-------|
| [`docs/rails7-asset-pipeline-audit.md`](../rails7-asset-pipeline-audit.md) | Sprockets 4 audit, gem constraints widened, manifest changes |
| [`docs/mongoid-8-embedded-document-migration.md`](../mongoid-8-embedded-document-migration.md) | Embedded document touch behavior audit and fix |
| [`docs/research/mongoid-upgrade-path.md`](research/mongoid-upgrade-path.md) | Mongoid 8/9 breaking changes, Workarea-specific impact analysis |
| [`docs/research/haml-rails7-compat.md`](research/haml-rails7-compat.md) | HAML 5.2 Rails 7 compatibility investigation |
| [`docs/research/rails7-dep-blockers.md`](research/rails7-dep-blockers.md) | Dependency resolution analysis, Rails 7.0 vs 7.1 blockers |
| [`docs/research/gem-dep-audit.md`](research/gem-dep-audit.md) | Full gem constraint audit |
| [`docs/source/articles/rails-7-migration-guide.html.md`](source/articles/rails-7-migration-guide.html.md) | Full migration reference guide (comprehensive) |

---

## FAQ

### Can I stay on Rails 6.1 temporarily?

Yes. Workarea's `next` branch maintains Rails 6.1 compatibility during the transition
period. Your existing application continues to work on the `next` branch's current
gem version without the Rails 7 upgrade.

However, Rails 6.1 reached end of life in June 2023. Security patches are no longer
backported. Plan your upgrade.

### How do I upgrade Rails incrementally?

Upgrade in this order to minimize simultaneous breakage:

1. Ruby (to 3.0+)
2. Non-Rails gems (security updates, Sidekiq 7, etc.)
3. Mongoid (7.4 → 8.1) — this is a **hard cut** alongside Rails 7
4. Rails (6.1 → 7.0)
5. Run test suite, fix failures

**Mongoid 7 and Rails 7 cannot coexist** — the Mongoid 7 gemspec explicitly requires
Rails ~> 6.x. The Mongoid 8 and Rails 7 upgrades must happen together.

### What about Rails 7.1?

Rails 7.1 support requires an additional `loofah` version bump (see
[`docs/research/rails7-dep-blockers.md`](research/rails7-dep-blockers.md)).
Workarea's current target is Rails 7.0. Rails 7.1 is tracked as a follow-up issue.

### What about my custom plugins?

Your plugins need the same code changes:
- Replace `update_attributes` → `update`
- Remove `require_dependency`
- Add Sprockets 4 engine manifests
- Add explicit `touch:` to `embedded_in` associations

Run `bin/rails zeitwerk:check` with plugins loaded to catch any naming issues.

### How do I verify everything is working?

See [Step 9: Final Verification](#step-9-final-verification). The short version:
`bin/rails zeitwerk:check` clean + full test suite passing + smoke test of checkout,
admin, and search.

---

*This guide reflects the state of PRs merged to the `next` branch as of March 2026.
Open an issue with label `rails-7-migration` if you encounter a scenario not covered here.*
