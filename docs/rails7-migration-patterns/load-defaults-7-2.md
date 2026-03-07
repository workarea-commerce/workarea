# Rails 7.2 `config.load_defaults` audit (Workarea)

This document catalogs the Rails 7.2 versioned defaults and assesses impact for the Workarea platform.

Source of truth for the default set: Rails Guides “Configuring Rails Applications” → **Versioned Default Values** → **Default Values for Target Version 7.2**.

## Current Workarea posture

Workarea dummy apps are currently pinned to `config.load_defaults 6.1` (see WA-VERIFY-003 / PR #775).

This audit is *documentation-first*: identify which 7.2 defaults matter for Workarea (and downstream client apps), and which are N/A.

## Rails 7.2 versioned defaults

| Setting | New default under `load_defaults 7.2` | Workarea impact | Notes / action |
|---|---:|---|---|
| `config.active_record.postgresql_adapter_decode_dates` | `true` | **N/A** | Workarea uses **Mongoid**, not ActiveRecord/PostgreSQL in core. Relevant only to downstream apps that add AR/PG.
| `config.active_record.validate_migration_timestamps` | `true` | **N/A** | ActiveRecord-only. Workarea’s migration system is Mongoid-based.
| `config.active_storage.web_image_content_types` | `%w(image/png image/jpeg image/gif image/webp)` | **Likely N/A** | Workarea uses **Dragonfly** by default (not ActiveStorage). If a downstream app enables ActiveStorage, this is probably safe.
| `config.yjit` | `true` | **N/A today / revisit later** | YJIT is Ruby 3.1+ only. Workarea currently targets Ruby 2.6 in mainline CI; Rails 7+ track will eventually move Ruby forward.

## Conclusion

For the Workarea platform itself, the Rails 7.2 versioned defaults appear to be **entirely N/A** (ActiveRecord/ActiveStorage) or **future-facing** (YJIT). No Workarea-specific shim or guardrail is recommended at this time.

## Follow-ups

- None required for Workarea core.
- If/when Workarea’s Rails 7.2 appraisal introduces additional non-N/A defaults (beyond the versioned defaults table above), expand this doc accordingly.
