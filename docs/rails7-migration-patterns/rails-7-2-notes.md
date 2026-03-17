# Rails 7.2 forward-compatibility notes (Workarea)

> Issue: https://github.com/workarea-commerce/workarea/issues/761
> Branch: `wa-forward-001-rails72-compat`

## Symptom

Attempting to bundle Workarea with Rails 7.2 fails immediately:

```
Because every version of workarea-core depends on rails >= 6.1, < 7.2
  and rails_7_2.gemfile depends on workarea-core >= 0,
  rails >= 6.1, < 7.2 is required.
So, because rails_7_2.gemfile depends on rails ~> 7.2.0,
  version solving has failed.
```

No test failures are visible yet because bundler cannot resolve the dependency graph.

## Root cause

`workarea-core` (and other Workarea component gems) have an explicit upper bound of
`rails < 7.2` in their gemspecs. This constraint must be relaxed before any Rails 7.2
compatibility testing can occur.

## Detection

```bash
# Check gemspec Rails constraints
grep -r "rails.*<" *.gemspec */workarea-*.gemspec 2>/dev/null || \
  grep -r "rails.*<" */lib/*/version.rb 2>/dev/null

# Attempt Rails 7.2 bundle (will fail — used to confirm the constraint)
BUNDLE_GEMFILE=gemfiles/rails_7_2.gemfile bundle install 2>&1 | grep "version solving"
```

## Fix

1. Relax the Rails upper bound in Workarea gemspecs (at least `workarea-core`) to allow
   Rails `~> 7.2`.
2. Once bundling succeeds, run the Workarea test suite under Rails 7.2 and capture failures.
3. Audit Workarea test configuration for `active_job.queue_adapter` expectations under
   Rails 7.2 (behavior changed — see notes below).
4. Check `config.force_ssl` usage in mailers/helpers (deprecated paths identified below).

---

## Summary

Attempting to add a Rails 7.2 appraisal Gemfile currently **does not bundle** due to an explicit Rails version constraint in Workarea.

**Current scope assessment:** **moderate**

* Rationale: The immediate blocker is mechanical (relax gemspec constraints), but we can’t yet see downstream dependency/test failures until bundler resolves.

## Bundler result

Created `gemfiles/rails_7_2.gemfile`:

```ruby
# frozen_string_literal: true

eval_gemfile File.expand_path('../Gemfile', __dir__)

gem 'rails', '~> 7.2.0'
```

Running `BUNDLE_GEMFILE=gemfiles/rails_7_2.gemfile bundle install` fails with:

```text
Because every version of workarea-core depends on rails >= 6.1, < 7.2
  and rails_7_2.gemfile depends on workarea-core >= 0,
  rails >= 6.1, < 7.2 is required.
So, because rails_7_2.gemfile depends on rails ~> 7.2.0,
  version solving has failed.
```

### Immediate blocker

`workarea-core` (and likely other Workarea component gems) has an upper bound of **`rails < 7.2`**. Until that constraint is relaxed, we cannot get a lockfile or run CI to discover *actual* Rails 7.2 incompatibilities.

## Rails 7.2 changes to watch (from release notes / upgrade guide)

Primary references:

* https://edgeguides.rubyonrails.org/7_2_release_notes.html
* https://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-7-1-to-rails-7-2

Notable items that could affect Workarea/apps:

* **Ruby minimum version is now 3.1** (Workarea is already running Ruby 3.2.7 in this assessment, so this is fine).
* **Active Job test behavior change**: in Rails 7.2, tests respect `config.active_job.queue_adapter` if explicitly set (previously some tests could still silently use the TestAdapter). If Workarea sets a non-test adapter in the test environment, or test assumptions relied on the implicit TestAdapter, expect failures.
* **Active Job transactional enqueue behavior**: Rails 7.2 defers enqueuing jobs until after commit when enqueued inside an Active Record transaction, and drops jobs on rollback. (Workarea is Mongoid-based, but apps/plugins may use Active Record, and this can surface as behavior changes in mixed environments.)
* **`alias_attribute` behavior change**: aliases bypass custom attribute methods and read raw DB value. (Quick scan: no `alias_attribute` usage found in Workarea itself.)

## Quick codebase scan

A quick grep for some historically-deprecated patterns surfaced:

* `Rails.application.config.force_ssl` usage in:
  * `storefront/app/mailers/workarea/storefront/application_mailer.rb`
  * `storefront/app/helpers/workarea/storefront/navigation_helper.rb`

This isn’t necessarily removed in 7.2, but it’s worth re-checking when the bundle resolves.

## Follow-up work (recommended issues)

1. Relax Rails upper bound in Workarea gemspecs (at least `workarea-core`) to allow bundler resolution with Rails 7.2.
2. Once bundling succeeds: run Workarea test suite under Rails 7.2 and capture failures/regressions.
3. Audit Workarea test configuration for `active_job.queue_adapter` expectations under Rails 7.2.

## Open questions

* After relaxing the Rails upper bound, do any dependency constraints (Mongoid, Sidekiq, etc.) prevent Rails 7.2 resolution?
* What CI matrix (if any) should be updated to include a Rails 7.2 appraisal run?

---

## References / Links

- [Rails 7.2 Release Notes](https://edgeguides.rubyonrails.org/7_2_release_notes.html)
- [Rails 7.2 Upgrade Guide](https://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-7-1-to-rails-7-2)
- [Issue #761](https://github.com/workarea-commerce/workarea/issues/761) — Rails 7.2 forward-compat tracking
- Related audit: [load-defaults-7-2.md](./load-defaults-7-2.md)
