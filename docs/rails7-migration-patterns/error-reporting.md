# Error reporting (Rails 7.1+)

Rails 7.1 introduced a framework-level error reporting API:

- `Rails.error.report(exception, handled:, severity:, context:)`

This is implemented by `ActiveSupport::ErrorReporter` and is intended to be
**configured by the host application** (or an integration gem) to forward handled
exceptions to a provider (Sentry, Bugsnag, Honeybadger, etc.).

## Verification status (WA-VERIFY-114)

**Status: ✅ Complete — audited and compatible.**

Workarea implements `Workarea::ErrorReporting` as a thin wrapper around
`Rails.error.report`. The wrapper is availability-guarded so it degrades
gracefully on Rails < 7.1. No client code changes are required.

## Current Workarea behavior

Workarea **does not ship with a bundled error reporting provider**.

Instead, Workarea relies on the host application to configure an error reporting
solution at the Rack / Rails level.

## Audited integration points

The audit found a small, additive integration surface only:

- `core/lib/workarea/error_reporting.rb` provides `Workarea::ErrorReporting`, a
  compatibility wrapper around `Rails.error.report`.
- `core/lib/workarea/latest_version.rb`,
  `core/lib/workarea/ping_home_base.rb`, and
  `core/app/models/workarea/checkout/fraud/analyzer.rb` use that wrapper for
  handled exceptions that Workarea intentionally rescues.
- `storefront/app/controllers/workarea/storefront/errors_controller.rb` sets
  `request.env['rack.exception']` for 500 responses so Rack-level reporters can
  observe unhandled exceptions through the normal middleware path.

No additional `ActiveSupport::ErrorReporter` subscribers, custom Rails error
reporter configuration, or provider-specific integrations are present in core.

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

**Rails 7.1's error reporting APIs do not introduce a compatibility break for
Workarea internals or extension points.**

- Workarea calls `Rails.error.report` **only when available**.
- Workarea does not require any provider.
- Existing error handling and Rack-based reporting continue to work unchanged.
- Extension points remain stable because host applications and plugins can opt
  into `config.error_reporter` without needing Workarea-specific changes.

This is useful primarily for *handled/swallowed* exceptions where otherwise the
host app may never learn about the error.

## Client impact

**None expected.** Existing applications, plugins, and downstream integrations do
not need code changes to remain compatible.

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
