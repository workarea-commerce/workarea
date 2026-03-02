---
title: Rails 7 Migration Guide
created_at: 2026/03/01
excerpt: A step-by-step guide for migrating downstream Workarea applications and plugins from Rails 6 to Rails 7, covering prerequisites, Gemfile changes, configuration, code updates, Mongoid 8, testing, and known issues.
---

# Rails 7 Migration Guide

This guide helps downstream users (client implementations and plugin authors) migrate their Workarea applications from Rails 6 to Rails 7. Follow each section in order and consult the [Known Issues](#known-issues) section if you encounter problems not covered here.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Gemfile Changes](#gemfile-changes)
3. [Configuration Changes](#configuration-changes)
4. [Code Changes](#code-changes)
5. [Mongoid 8 Migration](#mongoid-8-migration)
6. [Testing Changes](#testing-changes)
7. [Known Issues](#known-issues)
8. [FAQ](#faq)

---

## Prerequisites

Before upgrading, ensure your environment meets the minimum requirements.

### Ruby Version

Rails 7 requires **Ruby 2.7 or later**. Ruby 3.0+ is recommended.

\`\`\`bash
# Check your current Ruby version
ruby -v
# => ruby 3.0.x (recommended) or ruby 2.7.x (minimum)
\`\`\`

If you need to upgrade Ruby, use your version manager (rbenv, RVM, or asdf):

\`\`\`bash
# Example with rbenv
rbenv install 3.0.6
rbenv local 3.0.6
\`\`\`

Update your \`.ruby-version\` file accordingly.

### Node.js and Yarn

Workarea continues to use the asset pipeline with Sprockets. Ensure you have:

- Node.js: 14.x or later
- Yarn: 1.x (classic)

### Bundler

Use Bundler 2.2 or later:

\`\`\`bash
gem install bundler
bundler -v
\`\`\`

---

## Gemfile Changes

### Update the Rails Version

\`\`\`ruby
# Before (Rails 6)
gem 'rails', '~> 6.1'

# After (Rails 7)
gem 'rails', '~> 7.0'
\`\`\`

### Update Workarea

Ensure you are pointing to a Rails 7-compatible Workarea version (check release notes for the exact version).

### Sprockets 4

\`\`\`ruby
gem 'sprockets', '~> 4.0'
gem 'sprockets-rails', '>= 3.4.0'
\`\`\`

### Remove `rack-cache`

\`\`\`diff
-gem 'rack-cache'
\`\`\`

### Update Selenium for System Tests

\`\`\`ruby
gem 'selenium-webdriver', '>= 4.0'
\`\`\`

### Full Diff

\`\`\`diff
-gem 'rails', '~> 6.1'
+gem 'rails', '~> 7.0'

-gem 'sprockets', '~> 3.0'
+gem 'sprockets', '~> 4.0'
+gem 'sprockets-rails', '>= 3.4.0'

-gem 'rack-cache'

 gem 'bootsnap', '>= 1.4.4', require: false
\`\`\`

After updating, run:

\`\`\`bash
bundle update rails workarea
\`\`\`

---

## Configuration Changes

### Secrets → Credentials

Rails 7 fully removes \`config/secrets.yml\`. Use credentials instead.

**Before (\`config/secrets.yml\`):**

\`\`\`yaml
production:
  secret_key_base: abc123...
\`\`\`

**After — edit credentials:**

\`\`\`bash
EDITOR="nano" bin/rails credentials:edit
# or per-environment:
EDITOR="nano" bin/rails credentials:edit --environment production
\`\`\`

Replace references in code:

\`\`\`ruby
# Before
Rails.application.secrets.my_key

# After
Rails.application.credentials.my_key
\`\`\`

Delete \`config/secrets.yml\` once migrated.

### Remove rack-cache Configuration

\`\`\`diff
# config/environments/production.rb
-config.action_dispatch.rack_cache = { ... }
\`\`\`

### Zeitwerk Autoloader

Rails 7 defaults to Zeitwerk. Remove any classic autoloader configuration:

\`\`\`ruby
# config/application.rb — remove this line if present
# config.autoloader = :classic
\`\`\`

### Update `config.load_defaults`

\`\`\`ruby
# config/application.rb
# Before
config.load_defaults 6.1

# After
config.load_defaults 7.0
\`\`\`

Review each new default in the [Rails upgrade guide](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html).

### Host Authorization

Rails 7 enables host authorization middleware by default. Add your allowed hosts:

\`\`\`ruby
# config/environments/development.rb
config.hosts << "your-app.dev"

# config/environments/test.rb
config.hosts = nil
\`\`\`

---

## Code Changes

### `update_attributes` → `update`

`update_attributes` was removed in Rails 7.

\`\`\`ruby
# Before
record.update_attributes(name: 'Foo')
record.update_attributes!(name: 'Foo')

# After
record.update(name: 'Foo')
record.update!(name: 'Foo')
\`\`\`

Find all occurrences:

\`\`\`bash
grep -rn "update_attributes" app/ lib/
\`\`\`

### `to_s(:format)` → `to_formatted_s` or `strftime`

\`\`\`ruby
# Before
date.to_s(:long)
time.to_s(:short)

# After
date.to_formatted_s(:long)
time.to_formatted_s(:short)
# or
date.strftime('%B %d, %Y')
\`\`\`

Find all occurrences:

\`\`\`bash
grep -rn '\.to_s(:' app/ lib/
\`\`\`

### `require_dependency` Removed

Delete all `require_dependency` calls — Zeitwerk handles autoloading automatically.

\`\`\`ruby
# Before
require_dependency 'workarea/foo'

# After — delete the line entirely
# (use standard `require` only for files outside the autoload paths)
\`\`\`

\`\`\`bash
grep -rn "require_dependency" app/ lib/
\`\`\`

### Mailer Layouts

Rails 7 changed mailer layout application. Declare layouts explicitly if views break:

\`\`\`ruby
class MyMailer < ApplicationMailer
  layout 'mailer'
end
\`\`\`

---

## Mongoid 8 Migration

Workarea uses MongoDB via Mongoid. Rails 7 compatibility requires **Mongoid 8**.

### Gemfile

\`\`\`ruby
gem 'mongoid', '~> 8.0'
\`\`\`

### Breaking Changes

#### Strict Boolean Defaults

\`\`\`ruby
# Explicitly set defaults for boolean fields
field :active, type: Boolean, default: false
\`\`\`

#### Recursive Save Callbacks

Mongoid 8 prevents calling `save` inside `after_save` callbacks (it can recurse indefinitely).

Prefer to **avoid writes inside `after_save`** entirely. If you truly need to persist a derived field from within a callback, use a Mongoid-native atomic update that does not run callbacks again, such as `set`:

\`\`\`ruby
# Before
after_save { save }

# After (Mongoid)
after_save { set(field: value) }
\`\`\`

(Using `set` writes directly to MongoDB and bypasses validations and callbacks.)

#### Index Creation

After migrating, recreate indexes:

\`\`\`bash
rails db:mongoid:create_indexes
\`\`\`

### Update `config/mongoid.yml`

Remove deprecated options:

\`\`\`yaml
# Remove if present:
#   identity_map_enabled
#   allow_dynamic_fields (moved to model level)

development:
  clients:
    default:
      uri: <%= ENV['MONGODB_URI'] || 'mongodb://localhost:27017/my_app_development' %>
  options:
    belongs_to_required_by_default: false
\`\`\`

---

## Testing Changes

### System Tests

Update Capybara and Selenium:

\`\`\`ruby
# test/application_system_test_case.rb
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
end
\`\`\`

### Controller Test Host

\`\`\`ruby
# Before
@request.host = 'example.com'

# After
host! 'example.com'
\`\`\`

### FactoryBot

Update to FactoryBot 6.2+:

\`\`\`ruby
gem 'factory_bot_rails', '~> 6.2'
\`\`\`

### WebMock / VCR

Update for Ruby 3 Net::HTTP compatibility:

\`\`\`ruby
gem 'webmock', '>= 3.14'
gem 'vcr', '>= 6.1'
\`\`\`

---

## Known Issues

### `NameError: uninitialized constant` After Upgrade

**Cause:** Zeitwerk requires files to follow strict naming conventions.

**Fix:**

\`\`\`bash
bin/rails zeitwerk:check
\`\`\`

Rename files so that \`app/models/my_module/foo_bar.rb\` defines \`MyModule::FooBar\`.

---

### Asset Precompilation Failures

**Cause:** Sprockets 4 requires explicit manifest declarations.

**Fix:** Ensure \`app/assets/config/manifest.js\` exists:

\`\`\`js
//= link_tree ../images
//= link_directory ../stylesheets .css
//= link_directory ../javascripts .js
\`\`\`

---

### `ActionView::Template::Error` with `to_s` Format

**Cause:** \`Date#to_s(:format)\` removed in Rails 7.

**Fix:** Replace with \`to_formatted_s\` or \`strftime\`. See [Code Changes](#code-changes).

---

### Mongoid Recursive Save Error

**Cause:** Mongoid 8 prevents \`save\` inside \`after_save\` callbacks.

**Fix:** Avoid writes in \`after_save\`. If you must persist a derived field, use a Mongoid atomic update like \`set\` (see [Mongoid 8 Migration](#mongoid-8-migration)).

---

## FAQ

### How do I upgrade incrementally?

Upgrade in this order:

1. Ruby (to 3.0+)
2. Non-Rails gems
3. Mongoid (7 → 8)
4. Rails (6.x → 7.0)
5. Run test suite, fix failures

Use \`bin/rails app:update\` to get a diff of generated file changes.

---

### How do I migrate to Zeitwerk?

Check for violations:

\`\`\`bash
bin/rails zeitwerk:check
\`\`\`

Common fixes:
- Rename files to match class/module names exactly
- Move files into appropriate directories
- Replace \`require_dependency\` with nothing (Zeitwerk handles it) or \`require\`

Note: Rails 7 does not support the classic autoloader. Migration is required.

---

### How do I verify my upgrade is complete?

1. \`bin/rails zeitwerk:check\` — no errors
2. \`bin/rails test\` — full test suite passes
3. \`bin/rails test:system\` — system tests pass
4. Smoke test key flows locally (checkout, admin, search)
5. Review logs for remaining deprecation warnings

---

### Where do I report new issues?

Open an issue on the [Workarea GitHub repository](https://github.com/workarea-commerce/workarea) with the label \`rails-7-migration\`. Include your Ruby version, Workarea version, and a minimal reproduction.

---

*This guide will be updated as additional migration issues are discovered. Last updated: March 2026.*
