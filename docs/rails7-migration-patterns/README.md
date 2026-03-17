# Rails 7 Migration Patterns

This directory contains **opinionated, field-tested patterns** for upgrading Workarea applications to Rails 7.

These documents are primarily for downstream Workarea client applications.

Each pattern doc follows a consistent structure: **Symptom**, **Root cause**, **Detection**, **Fix**, and **References / Links**.

## Patterns

| Document | Description |
|----------|-------------|
| [Assets Pipeline — Webpacker Removal / Sprockets 4 / Propshaft](./assets-pipeline-webpacker-removal.md) | Remove Webpacker and migrate to Sprockets 4, Propshaft, or jsbundling-rails in Rails 7. |
| [BigDecimal / Money Serialization](./bigdecimal-money-serialization.md) | Fix precision loss and type errors when `BigDecimal`/`Money` values cross JSON or cache boundaries in Rails 7. |
| [Deprecation Sweep Results](./deprecation-sweep-results.md) | Record of Rails 6.1–7.x deprecation sweeps; known categories addressed and follow-up audit issues. |
| [Error Reporting (Rails 7.1+)](./error-reporting.md) | How Workarea integrates with the Rails 7.1 `ActiveSupport::ErrorReporter` API for handled exceptions. |
| [Optional: jsbundling-rails (esbuild) + Sprockets](./jsbundling-rails-esbuild.md) | For apps that need modern JS tooling (ESM, npm, TypeScript) alongside Sprockets in Rails 7. |
| [Rails 7.2 `config.load_defaults` Audit](./load-defaults-7-2.md) | Audit of Rails 7.2 versioned defaults and their impact (or non-impact) on Workarea. |
| [Middleware Stack / Ordering Changes](./middleware-stack-ordering.md) | Fix `403 Blocked host` errors caused by `ActionDispatch::HostAuthorization` inserted early in the Rails 7 middleware stack. |
| [Rails 7.2 Forward-compatibility Notes](./rails-7-2-notes.md) | Bundler blockers and known Rails 7.2 changes to watch when relaxing Workarea's Rails upper bound. |
| [Sprockets 4 manifest.js Format Changes](./sprockets-manifest-format.md) | Fix missing assets after Sprockets 4 upgrade by creating/updating the explicit `manifest.js`. |
| [URL/Routing Helper Behavior Changes](./url-routing-helpers.md) | Fix `default_url_options` not applying in background jobs, mailers, or console in Rails 7. |
| [Webpacker → Sprockets 4](./webpacker-to-sprockets-4.md) | Step-by-step migration from Webpacker to Sprockets 4 for Workarea host applications (recommended default path). |
| [Zeitwerk Notes](./zeitwerk-notes.md) | Zeitwerk autoloader compatibility audit for Workarea engines; edge cases and check commands. |
