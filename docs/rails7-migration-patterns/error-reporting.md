# Error reporting (Rails 7.1+)

Rails 7.1 introduced a framework-level error reporting API:

- `Rails.error.report(exception, handled:, severity:, context:)`

This is implemented by `ActiveSupport::ErrorReporter` and is intended to be
**configured by the host application** (or an integration gem) to forward handled
exceptions to a provider (Sentry, Bugsnag, Honeybadger, etc.).

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

- Raised normally (and therefore captured by the host app’s exception handling), or
- Rescued and logged in a few places where Workarea intentionally swallows the
  error (for example: version checks / telemetry-like pings).

## Decision

**Adopt Rails 7.1’s error reporting API as an additive, opt-in hook.**

This means:

- Workarea will call `Rails.error.report` **only when available**.
- Workarea will not require any provider.
- Existing error handling continues to work unchanged.

This is useful primarily for *handled/swallowed* exceptions where otherwise the
host app may never learn about the error.

## Implementation notes

- Add `Workarea::ErrorReporting.report` as a small wrapper around
  `Rails.error.report`.
- Use it in places where Workarea rescues and continues (handled errors), with
  `severity: :warning` and some lightweight context.

Host applications can configure Rails’ error reporter via `config.error_reporter`
(or via a provider gem that integrates with `ActiveSupport::ErrorReporter`).
