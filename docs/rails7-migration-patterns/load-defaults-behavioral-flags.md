# `config.load_defaults` — behavioral flags checklist (Workarea)

Rails upgrades can introduce **silent behavioral changes** when an app bumps `config.load_defaults`.
Workarea is an engine, but it ships **dummy applications** used in test/appraisal contexts; downstream client apps will also bump `load_defaults` during upgrades.

This doc is a **short, high-signal checklist** of the highest-risk `load_defaults`-gated changes we want to keep an eye on during the Rails 7 track.

## Current state (repo)

Workarea does **not** set `config.load_defaults` in the engine itself.
The only `load_defaults` usage in this repo is in the dummy applications:

- `admin/test/dummy/config/application.rb` → `config.load_defaults 6.1`
- `core/test/dummy/config/application.rb` → `config.load_defaults 6.1`
- `storefront/test/dummy/config/application.rb` → `config.load_defaults 6.1`

Reference audit: `docs/verification/wa-verify-003-load-defaults-audit.md`.

## Top 5 risky `load_defaults` items (focus list)

These are the ones most likely to produce **client-visible regressions** when a downstream app (or our dummies under appraisal) bumps defaults.

1) **Cookie / signed message serialization**
   - Risk: session invalidation, login/logout weirdness, cross-deploy compatibility.
   - Related knobs:
     - `action_dispatch.cookies_serializer`
     - `active_support.message_serializer` (7.1)
     - `active_support.use_message_serializer_for_metadata` (7.1)
   - Workarea already sets `action_dispatch.cookies_serializer = :hybrid` in `core/config/initializers/22_session_store.rb` to support rolling upgrades.

2) **Cache serialization format changes**
   - Risk: cache poisoning / cache misses across deploys; subtle performance issues.
   - Related knob:
     - `active_support.cache_format_version` (7.0 / 7.1)
   - Approach: treat cache format bumps as a **deploy-coordinated change** (flush or dual-read strategy).

3) **Autoload / `$LOAD_PATH` behavior**
   - Risk: production-only load errors, Zeitwerk edge cases.
   - Related knob:
     - `add_autoload_paths_to_load_path = false` (7.1)

4) **Middleware / request behavior defaults**
   - Risk: behavior drift around content negotiation, headers, etc.
   - Examples:
     - `action_dispatch.default_headers` changes (7.0)
     - `action_dispatch.return_only_request_media_type_on_content_type` (7.0)

5) **Redirect safety defaults**
   - Risk: breaking previously-allowed redirects; security hardening that might surface as app errors.
   - Related knob:
     - `action_controller.raise_on_open_redirects` (7.0)

## What to do when bumping `load_defaults`

When we change the dummy apps’ `config.load_defaults` (or advise clients to do so), do a quick pass over the focus list above and add/confirm guardrails:

- Confirm cookie/session compatibility plan (especially for multi-node rolling deploys)
- Confirm cache plan (flush vs dual-format) and document expected behavior
- Run zeitwerk checks and watch for `$LOAD_PATH` assumptions
- Snapshot middleware stack (`bin/rails middleware`) and confirm any ordering-sensitive logic still holds

## Guardrails

A lightweight guardrail test exists to force an explicit decision whenever someone changes the dummy apps’ `load_defaults`.
See: `core/test/integration/workarea/load_defaults_guardrail_test.rb`.
