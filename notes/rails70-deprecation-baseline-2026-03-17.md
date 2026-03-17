# Rails 7.0 deprecation baseline (WA-VERIFY-071)

Date: 2026-03-17

## Environment

- Appraisal / Gemfile: `gemfiles/rails_7_0.gemfile`
- Ruby: `2.7.8p225` (arm64-darwin25)
- Rails: `7.0.10` (`BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle exec rails --version`)

## Notes about bundle setup

Bundler initially failed with:

> `Bundler::GemNotFound: Could not find date-3.5.1 in locally installed gems`

The `date-3.5.1` gem exists on RubyGems, but Bundler failed to download/install it during `bundle install`.

Workaround used to proceed:

```bash
cd /Users/Shared/openclaw/projects/workarea-modernization/repos/workarea
BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle install
gem fetch date -v 3.5.1
gem install ./date-3.5.1.gem --no-document --install-dir ./gemfiles/vendor/bundle/ruby/2.7.0
BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle exec rails --version
```

## Deprecation warning count

### Attempt 1: per task instructions

Command:

```bash
BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle exec rake test 2>&1 | grep "DEPRECATION WARNING" | wc -l
```

Result:

- `rake test` did **not** run the test suite under Rails 7.0; it printed the `rails new` usage banner and exited.
- Deprecation warning count: **0** (because tests did not actually run)

### Attempt 2: run the per-gem test tasks directly

Command:

```bash
BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle exec rake core_test admin_test storefront_test
```

Result:

- Test suite aborts during initialization (before any tests run):

```
uninitialized constant Workarea::EnforceHostMiddleware (NameError)
.../core/config/initializers/10_rack_middleware.rb:56
```

- Deprecation warning count: **0** (aborted before warnings could be emitted)

## Sample warnings (first 10)

None captured — Rails 7.0 appraisal cannot currently boot the test environment due to the `Workarea::EnforceHostMiddleware` NameError.

## Observations

- Rails 7.0.10 boot under appraisal currently fails early in `core/test/dummy` initialization due to `Workarea::EnforceHostMiddleware` missing.
- The top-level `rake test` task appears incompatible with the Rails 7.0 appraisal in its current form (prints `rails new` help instead of running tests).
