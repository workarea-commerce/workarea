# Error reporting (Rails 7.1+)

Rails 7.1 introduced a framework-level error reporting API:

- `Rails.error.report(exception, handled:, severity:, context:)`

This is implemented by `ActiveSupport::ErrorReporter` and is intended to be
**configured by the host application** (or an integration gem) to forward handled
exceptions to a provider (Sentry, Bugsnag, Honeybadger, etc.).

## Symptom

After upgrading to Rails 7.1, handled/swallowed exceptions inside Workarea are no longer
forwarded to external error tracking providers (Sentry, Bugsnag, Honeybadger, etc.).
Previously, these may have been captured by Rack middleware or a gem monkey-patch.
In Rails 7.1+, the new `ActiveSupport::ErrorReporter` API must be used instead.

## Root cause

Rails 7.1 added `Rails.error` as the canonical way to report handled errors to configured
subscribers. Without calling `Rails.error.report`, handled exceptions swallowed inside
Workarea code paths are invisible to error reporting tools. Workarea added
`Workarea::ErrorReporting` as a thin wrapper to bridge this gap.

## Detection

```bash
# Confirm the module exists:
grep -r "ErrorReporting" core/lib/ --include="*.rb"
# → core/lib/workarea/error_reporting.rb

# Confirm no hard dependency on Rails.error (availability-guarded):
grep -n "rails_error_reporter_available" core/lib/workarea/error_reporting.rb

# Confirm no provider hard-coded:
grep -rn "Sentry\|Bugsnag\|Honeybadger\|Airbrake" core/lib/workarea/error_reporting.rb
# → (no output — no provider is hard-coded)
```

## Fix

Workarea implements `Workarea::ErrorReporting.report` which calls `Rails.error.report`
when available (Rails 7.1+) and degrades gracefully on older versions. No client code
changes are required.

To configure an error reporting provider in your host application:

```ruby
# config/initializers/error_reporting.rb
# Example: Sentry
Rails.error.subscribe(Sentry::Rails::ErrorSubscriber.new)
```

---

## Verification status (WA-VERIFY-044)

**Status: ✅ Complete — implemented and compatible.**

Workarea implements `Workarea::ErrorReporting` as a thin wrapper around
`Rails.error.report`. The wrapper is availability-guarded so it degrades
gracefully on Rails < 7.1. No client code changes are required.

## Current Workarea behavior

Workarea **does not ship with a bundled error reporting provider**.

Instead, Workarea relies on the host application to configure an error reporting
solution at the Rack / Rails level.

Examples:

- Storefront error pages set `request.env['rack.exception']` in
  `Workarea::Storefront::ErrorsController#internal` so Rack middleware (and error
  reporters that hook into it) can see the exception.
- Workarea has optional provider integrations via separate plugins (e.g.
  `workarea-sentry`).

In core Workarea code, most exceptions are either:

- Raised normally (and therefore captured by the host app's exception handling), or
- Rescued and logged in a few places where Workarea intentionally swallows the
  error (for example: version checks / telemetry-like pings).

## Implementation

`core/lib/workarea/error_reporting.rb` provides `Workarea::ErrorReporting.report`:

- Calls `Rails.error.report` if the reporter is available (Rails 7.1+).
- Falls back silently on Rails < 7.1 — no breakage.
- Wraps the reporter call in a rescue to prevent error-reporting failures from
  impacting runtime behavior.

Host applications can configure Rails' error reporter via `config.error_reporter`
(or via a provider gem that integrates with `ActiveSupport::ErrorReporter`).

## Decision

**Adopted Rails 7.1's error reporting API as an additive, opt-in hook:**

- Workarea calls `Rails.error.report` **only when available**.
- Workarea does not require any provider.
- Existing error handling continues to work unchanged.

This is useful primarily for *handled/swallowed* exceptions where otherwise the
host app may never learn about the error.

## Verification commands

```bash
# Confirm the module exists:
grep -r "ErrorReporting" core/lib/ --include="*.rb"
# → core/lib/workarea/error_reporting.rb

# Confirm no hard dependency on Rails.error (availability-guarded):
grep -n "rails_error_reporter_available" core/lib/workarea/error_reporting.rb

# Confirm no provider hard-coded:
grep -rn "Sentry\|Bugsnag\|Honeybadger\|Airbrake" core/lib/workarea/error_reporting.rb
# → (no output — no provider is hard-coded)
```

---

## References / Links

- [Rails 7.1 Error Reporting API](https://edgeguides.rubyonrails.org/error_reporting.html)
- [ActiveSupport::ErrorReporter docs](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html)
- [WA-VERIFY-044 — implementation issue](https://github.com/workarea-commerce/workarea/issues)
- [Rails 7.1 Release Notes](https://edgeguides.rubyonrails.org/7_1_release_notes.html)
