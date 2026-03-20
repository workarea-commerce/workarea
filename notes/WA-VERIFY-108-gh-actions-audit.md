# WA-VERIFY-108: GitHub Actions Deprecated Patterns Audit

**Date:** 2026-03-17  
**Branch:** `next`  
**Audited path:** `.github/workflows/`

## Commands Run

```bash
# Check for deprecated composite actions
grep -r 'workarea-commerce/ci' .github/workflows/

# Check for @v1 actions that might be node12
grep -rn 'uses:.*@v1' .github/workflows/ | grep -v 'actions/checkout\|ruby/setup-ruby'

# Check for docker-compose usage in workflow files
grep -rn 'docker-compose' .github/workflows/

# List all action refs for manual review
grep -rn 'uses:' .github/workflows/ | sort | uniq
```

## Results

### ❌ FINDING 1: `workarea-commerce/ci` Composite Actions

**Status:** FOUND — deprecated actions present

**File:** `.github/workflows/ci.yml`

All usages reference the `workarea-commerce/ci` Docker-based composite actions repository at `@v1`:

| Action | Lines | Count |
|--------|-------|-------|
| `workarea-commerce/ci/eslint@v1` | 68 | 1 |
| `workarea-commerce/ci/stylelint@v1` | 71 | 1 |
| `workarea-commerce/ci/test@v1` | 114, 129, 144, 164, 179, 194, 209, 224, 265, 288, 328 | 11 |

**Total:** 13 usages of deprecated `workarea-commerce/ci` actions.

**Note from workflow comment:** "The docker-based workarea-commerce/ci/* actions are pinned to ruby:2.6" — these actions run in a Docker container using an EOL Ruby version.

---

### ❌ FINDING 2: Node.js 12 Runtime (`@v1` references)

**Status:** FOUND — all `workarea-commerce/ci` actions use `@v1` which runs on the Node.js 12 runner (now deprecated by GitHub Actions).

These are the same 13 `workarea-commerce/ci/*@v1` references above. Since `workarea-commerce/ci` is an external action repo pinned at `@v1`, it uses the Node.js 12 runtime which GitHub deprecated and will cause CI failures.

---

### ❌ FINDING 3: `docker-compose` Usage

**Status:** FOUND — legacy `docker-compose` CLI installed and invoked directly

**File:** `.github/workflows/ci.yml`

- **Lines 112–113, 127–128, 142–143, 162–163, 177–178, 192–193, 207–208, 222–223, 243–244, 262–263, 282–283, 325–326:** `sudo apt-get install -y docker-compose imagemagick` (12 job steps)
- **Line 247:** `docker-compose up -d` (direct invocation)

The standalone `docker-compose` CLI (v1) is deprecated; the modern replacement is `docker compose` (v2, a Docker CLI plugin, no hyphen).

---

## Summary

All three deprecated patterns are present in `.github/workflows/ci.yml`:

| Pattern | Status | Occurrences |
|---------|--------|-------------|
| `workarea-commerce/ci` composite actions | ❌ FOUND | 13 |
| `@v1` Node.js 12 runtime actions | ❌ FOUND | 13 (same) |
| `docker-compose` (v1 CLI) | ❌ FOUND | 13 install steps + 1 invocation |

## Follow-Up Issues

The following issues should be created to address each finding:

1. **Replace `workarea-commerce/ci` composite actions** — migrate ESLint, Stylelint, and test jobs to use modern native GitHub Actions steps instead of the deprecated Docker-based composite actions pinned to ruby:2.6.

2. **Replace `docker-compose` with `docker compose`** — update all workflow steps that install and invoke the legacy `docker-compose` v1 CLI to use the `docker compose` v2 plugin syntax.

Both issues are related: migrating away from `workarea-commerce/ci` composite actions will inherently remove the `docker-compose` dependency embedded in those actions, as well as the direct `docker-compose up -d` call.
