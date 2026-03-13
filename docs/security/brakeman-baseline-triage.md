# Brakeman Baseline — Accepted Warnings Triage

The Brakeman baseline (`core/brakeman.baseline.json`) suppresses warnings that
were present at the time the weekly security scan was introduced.  This file is
the canonical record of **why** each warning is in the baseline: either a
tracking issue exists to fix it, or risk acceptance has been deliberately
documented.

> **Never add a warning to the baseline without updating this table.**
> See [Updating the baseline](#updating-the-baseline) at the bottom of this
> page.

---

## Warning inventory (11 items — baseline captured 2026-03-13)

| # | Brakeman type | Confidence | File | Tracking issue | Status / Rationale |
|---|---------------|------------|------|----------------|--------------------|
| 1 | **Path Traversal** (code 108) | High | `workarea-core.gemspec:55` | [#811](https://github.com/workarea-commerce/workarea/issues/811) — Upgrade sprockets ≥ 3.7.2 (CVE-2018-3760) | 🔴 Active — sprockets constraint in gemspec must be tightened |
| 2 | **Remote Code Execution** (code 24) | High | `app/queries/workarea/admin_search_query_wrapper.rb:27` | [#807](https://github.com/workarea-commerce/workarea/issues/807) — Address unsafe `constantize` warnings | 🔴 Active — `params[:model_type].constantize` is scoped to admin but needs an allowlist |
| 3 | **Remote Code Execution** (code 24) | Medium | `app/models/workarea/catalog/customizations.rb:46` | [#807](https://github.com/workarea-commerce/workarea/issues/807) — Address unsafe `constantize` warnings | 🔴 Active — `constantize` on a model attribute; allowlist enforcement pending |
| 4 | **SSL Verification Bypass** (code 71) | High | `lib/workarea/latest_version.rb:11` | [#808](https://github.com/workarea-commerce/workarea/issues/808) — Remove `SSL VERIFY_NONE` usage | 🔴 Active — `VERIFY_NONE` used when checking rubygems.org for updates |
| 5 | **SSL Verification Bypass** (code 71) | High | `lib/workarea/ping_home_base.rb:18` | [#808](https://github.com/workarea-commerce/workarea/issues/808) — Remove `SSL VERIFY_NONE` usage | 🔴 Active — `VERIFY_NONE` used for home-base ping; endpoint may be decommissioned |
| 6 | **Unmaintained Dependency** (code 120) | High | `workarea-core.gemspec:18` | Rails 7 upgrade track: [#768](https://github.com/workarea-commerce/workarea/issues/768), [#793](https://github.com/workarea-commerce/workarea/issues/793), [#792](https://github.com/workarea-commerce/workarea/issues/792) | 🟡 Long-running — Rails 6.1 reached EOL 2024-10-01; upgrade is the strategic fix |
| 7 | **Cross-Site Request Forgery** (code 86) | Medium | `app/controllers/workarea/application_controller.rb` | _(no separate issue — risk accepted; see rationale)_ | 🟢 Accepted — `protect_from_forgery` is called without `with: :exception`.  Changing to `:exception` would break API-style callers that rely on the `null_session` strategy (the Rails default before Rails 5.2). Revisit if/when API callers are audited. |
| 8 | **Remote Code Execution** (code 110) | Medium | `config/initializers/22_session_store.rb:27` | _(no separate issue — risk accepted; see rationale)_ | 🟢 Accepted — `:hybrid` serializer is the documented zero-downtime migration strategy from Marshal → JSON sessions (see comment in file and [#725](https://github.com/workarea-commerce/workarea/issues/725)). Switch to `:json` once all in-flight sessions have expired. |
| 9 | **Command Injection** (code 14) | Medium | `lib/workarea/tasks/cache.rb:32` | _(no separate issue — risk accepted; see rationale)_ | 🟢 Accepted — The `curl` invocation is in a Rake task (never executed in a request cycle). The URL is built from `Workarea::Image` route helpers using an internal CDN path — not from user-supplied input. Exposure is limited to operators running rake tasks in a trusted environment. Track for removal when the Rake task is refactored. |
| 10 | **Remote Code Execution** (code 25) | Weak | `lib/workarea/elasticsearch/serializer.rb:38` | _(no separate issue — risk accepted; see rationale)_ | 🟢 Accepted — `Marshal.load` deserializes data written by Workarea itself to an internal Redis cache, not data from user requests. The serializer is called only within the application's own Elasticsearch integration. Risk is low; prefer JSON serialization long-term. |
| 11 | **Dangerous Eval** (code 13) | Weak | `lib/workarea/ext/mongoid/list_field.rb:4` | _(no separate issue — risk accepted; see rationale)_ | 🟢 Accepted — `eval` in this Mongoid extension evaluates a static, developer-authored type string during class definition (not at request time). The string is not derived from user input. This is a Mongoid internal pattern; track for removal if the list field is ever rewritten. |

**Legend:** 🔴 Active tracking issue | 🟡 Covered by broader upgrade track | 🟢 Risk accepted with documented rationale

---

## Updating the baseline

The baseline file is `core/brakeman.baseline.json`.  It is used by the
[weekly security scan](.github/workflows/weekly-security-scan.yml) and (once
merged) the PR-level Brakeman CI check.

### When to update

| Scenario | Action |
|----------|--------|
| A warning in the table above is **fixed** | Remove the warning from `core/brakeman.baseline.json` **and** update (or close) the row in this table. |
| A **new** pre-existing warning is discovered and intentionally deferred | Add it to `core/brakeman.baseline.json` **and** add a new row to this table with either a tracking issue or explicit rationale.  Do not add to the baseline silently. |
| A warning turns out to be a **false positive** | Add it to the baseline, annotate this table with `🟢 False positive — <reason>`, and optionally open a Brakeman upstream report. |

### How to regenerate the baseline

```sh
# From the repo root (requires brakeman in bundle)
cd core
bundle exec brakeman --format json --output brakeman.baseline.json
```

Or use the wrapper script once [#897](https://github.com/workarea-commerce/workarea/issues/897) is resolved.

Commit both `core/brakeman.baseline.json` **and** your update to this file in
the same PR so the two stay in sync.

---

*First populated: 2026-03-13 — see [#979](https://github.com/workarea-commerce/workarea/issues/979).*
*Index of all Brakeman findings → issues: see [docs/security/brakeman-findings-index.md](brakeman-findings-index.md) (tracked in [#882](https://github.com/workarea-commerce/workarea/issues/882)).*
