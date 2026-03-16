# Brakeman Findings Index

This page maps Brakeman warning categories to the active issues and PRs that
track remediation. It is the **quick-reference companion** to the detailed
triage table in [brakeman-baseline-triage.md](./brakeman-baseline-triage.md).

> **Keep this in sync.** When a new WA-SEC issue is opened or closed, update
> the table below.

---

## Finding Categories

### 1 · Unsafe Constantize (Remote Code Execution — code 24)

`constantize` called on user-controlled or model-derived strings without an
allowlist, creating potential RCE gadgets.

| Ref | Title | Status |
|-----|-------|--------|
| [#802](https://github.com/workarea-commerce/workarea/issues/802) | Security: Brakeman findings — params-driven constantize (potential RCE) | 🔴 Open |
| [#807](https://github.com/workarea-commerce/workarea/issues/807) | Security: Address Brakeman unsafe constantize warnings | 🔴 Open — changes requested |

**Affected files (from baseline):**
- `app/queries/workarea/admin_search_query_wrapper.rb:27`
- `app/models/workarea/catalog/customizations.rb:46`

---

### 2 · Dynamic Render Path (code varies)

`render` action or template name derived from params, allowing potential
template-injection or directory traversal.

| Ref | Title | Status |
|-----|-------|--------|
| [#804](https://github.com/workarea-commerce/workarea/issues/804) | Security: Brakeman Dynamic Render Path warnings | 🔴 Open |
| [#809](https://github.com/workarea-commerce/workarea/issues/809) | Security: Audit dynamic render paths flagged by Brakeman | 🔴 Open |
| [#876](https://github.com/workarea-commerce/workarea/issues/876) | WA-SEC-014: Eliminate Brakeman Dynamic Render Path warnings via allowlists | 🔴 Open — changes requested |

---

### 3 · Weak Hash / SHA1 Digest (WeakHash — code 6)

`Digest::SHA1` or `OpenSSL::Digest::SHA1` used for security-sensitive
operations (tokens, fingerprints).

| Ref | Title | Status |
|-----|-------|--------|
| [#805](https://github.com/workarea-commerce/workarea/issues/805) | Security: Replace SHA1 usage flagged by Brakeman (WeakHash) | 🔴 Open |
| [#810](https://github.com/workarea-commerce/workarea/issues/810) | Security: Replace SHA1 hashing flagged by Brakeman | 🔴 Open |
| [#875](https://github.com/workarea-commerce/workarea/issues/875) | WA-SEC-013: Replace SHA1 digest usage flagged by Brakeman | 🔴 Open — changes requested |

---

### 4 · SSL Verify None (SSLVerify — code 71)

`OpenSSL::SSL::VERIFY_NONE` disables certificate verification, enabling
man-in-the-middle attacks.

| Ref | Title | Status |
|-----|-------|--------|
| [#803](https://github.com/workarea-commerce/workarea/issues/803) | Security: Remove/limit OpenSSL::SSL::VERIFY_NONE (Brakeman SSLVerify) | 🔴 Open |
| [#808](https://github.com/workarea-commerce/workarea/issues/808) | Security: Remove SSL VERIFY_NONE usage | 🔴 Open — changes requested |

**Affected files (from baseline):**
- `lib/workarea/latest_version.rb:11`
- `lib/workarea/ping_home_base.rb:18`

---

### 5 · Path Traversal / Unmaintained Dependency (code 108/120)

Sprockets `< 3.7.2` is vulnerable to CVE-2018-3760. Both the path-traversal
Brakeman code and the unmaintained-dependency code fire until sprockets is
upgraded.

| Ref | Title | Status |
|-----|-------|--------|
| [#811](https://github.com/workarea-commerce/workarea/issues/811) | Security: Upgrade sprockets to ≥ 3.7.2 (CVE-2018-3760) | 🔴 Open — changes requested |

---

## Intentionally Deferred Items

The findings below are in the Brakeman baseline (`core/brakeman.baseline.json`)
with deliberate risk-acceptance. They will **not** be fixed in the near term and
should not be assigned WA-SEC issues unless the rationale changes.

| Brakeman type | File | Rationale | Revisit trigger |
|---------------|------|-----------|-----------------|
| CSRF (code 86) | `app/controllers/workarea/application_controller.rb` | `protect_from_forgery` uses `null_session` strategy intentionally to avoid breaking API callers. Changing to `:exception` would be a breaking change. | Audit API callers / API auth redesign |
| Unsafe Deserialization (code 110) | `config/initializers/22_session_store.rb` | `:hybrid` serializer is the documented zero-downtime migration from Marshal → JSON sessions per [#725](https://github.com/workarea-commerce/workarea/issues/725). | Switch to `:json` once in-flight sessions expire |
| Command Injection (code 14) | `lib/workarea/tasks/cache.rb` | `curl` in Rake task; URL built from internal route helpers, not user input. Operator-only context. | Refactor or removal of the Rake task |
| Unsafe Deserialization (code 25) | `lib/workarea/elasticsearch/serializer.rb` | `Marshal.load` on data the app itself wrote to Redis (not request input). | JSON-serialization rewrite of the Elasticsearch serializer |
| Dangerous Eval (code 13) | `lib/workarea/ext/mongoid/list_field.rb` | `eval` on a static developer-authored type string at class-load time, not request time. | Rewrite of Mongoid list field extension |

For the full rationale and per-warning notes, see
[brakeman-baseline-triage.md](./brakeman-baseline-triage.md).

---

## Infrastructure Issues

| Ref | Title | Status |
|-----|-------|--------|
| [#806](https://github.com/workarea-commerce/workarea/issues/806) | Chore: Add Brakeman to bundle | 🔴 Blocked |
| [#835](https://github.com/workarea-commerce/workarea/issues/835) | WA-VERIFY-021: Rails 7.2 appraisal — Brakeman scan snapshot + follow-ups | 🔴 Blocked |
| [#880](https://github.com/workarea-commerce/workarea/issues/880) | WA-CI-013: Run Brakeman in CI on PRs | 🔴 In progress |
| [#897](https://github.com/workarea-commerce/workarea/issues/897) | WA-VERIFY-040: Add repo-root Brakeman wrapper script | 🔴 Blocked — needs owner |
| [#980](https://github.com/workarea-commerce/workarea/issues/980) | WA-SEC-018: Sanitize Brakeman baseline metadata to reduce churn | 🔴 In progress |

---

## Related Docs

- [brakeman-baseline-triage.md](./brakeman-baseline-triage.md) — Full warning
  inventory with per-line rationale
- [SECURITY.md](../../SECURITY.md) — Responsible disclosure policy
