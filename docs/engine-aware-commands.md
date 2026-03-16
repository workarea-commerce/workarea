# Engine-Aware Commands

Workarea is split into three engines — **core**, **admin**, and **storefront**.
There is no single `bin/rails` at the repo root. Instead, each engine has its
own Rails environment under its directory.

## Running tests

Use `script/test` from the repo root — it handles Node version pinning and
environment setup automatically.

```bash
# Full suite for one engine
script/test core
script/test admin
script/test storefront

# Single test file
script/test core test/models/workarea/user_test.rb

# Single test by name
script/test core test/models/workarea/user_test.rb -n test_email_address
```

## Running Rails commands per engine

To run Rails generators, console, or runner commands, `cd` into the engine
directory first:

```bash
# Rails console for core
cd core && bundle exec rails console

# Rails runner for admin
cd admin && bundle exec rails runner 'puts Workarea::VERSION'

# Generate a migration in core
cd core && bundle exec rails generate migration AddFooToBar
```

Always return to the repo root (`cd ..`) before switching engines.

## Common mistakes

| What you tried | Why it fails | What to do instead |
|---|---|---|
| `bin/rails test` from repo root | No `bin/rails` at root | `script/test <engine>` |
| `bundle exec rails c` from root | No Rails app at root | `cd core && bundle exec rails c` |
| `rake db:migrate` from root | No Rakefile configured for engines | `cd core && bundle exec rake db:migrate` |

## Which engine?

| You want to… | Engine |
|---|---|
| Test models, services, workers | `core` |
| Test admin UI, controllers | `admin` |
| Test storefront views, system tests | `storefront` |
