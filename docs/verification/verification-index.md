# Verification Index — Scripts & Common Local Commands

A quick-reference map for pre-PR checks, local test runs, and the verification docs
available in this directory.

---

## Available verification scripts

| Script | What it does |
|--------|--------------|
| `script/test [component]` | Runs the test suite for one engine (`core`, `admin`, `storefront`, or `testing`). Forces Node 18 for ExecJS, skips system tests by default. |
| `script/clean` | Removes test logs, capybara screenshots, and documentation build artifacts for all engines. Run this when stale state causes false failures. |
| `script/default_appraisal_boot_smoke` | Verifies the default `Gemfile.lock` stack can boot Rails in test mode (no appraisal required). |
| `script/docker_services_health` | Checks that the required Docker containers (MongoDB, Redis, Elasticsearch) are running. Safe/read-only — does not start or stop containers. |
| `script/docker_services_status` | Prints current status of Workarea-related Docker containers. |
| `script/docker_services_versions` | Shows version tags of the running Docker service containers. |
| `script/elasticsearch_http_check` | Curls localhost:9200 and reports whether Elasticsearch is responding. |
| `script/check_service_ports` | Checks that the expected ports (27017, 6379, 9200) are open and accepting connections. |
| `script/preflight` | Runs a suite of common pre-PR checks (ports, boot smoke, RuboCop). |
| `script/system_prereqs` | Installs/verifies system prerequisites (Docker, Docker Compose, ImageMagick). Reused in CI. |
| `script/verify` | Runs a combined local verification suite (prerequisites, services, boot, lint). |
| `script/default_appraisal_deprecations` | Checks for deprecated API usage in the default appraisal. |
| `script/default_appraisal_zeitwerk_check` | Validates Zeitwerk autoloading compatibility in the default appraisal. |
| `scripts/run-benchmarks.sh` | Executes the benchmark suite under `docs/benchmarks/`. |

### `script/test` usage examples

```bash
# Run the full core suite
script/test core

# Run a single test file in admin
script/test admin test test/integration/workarea/admin/foo_test.rb

# Run storefront tests matching a pattern
script/test storefront test test/integration/workarea/storefront/*_test.rb
```

### `script/docker_services_health` usage example

```bash
# Check that mongo, redis, and elasticsearch containers are running
script/docker_services_health
# PASS: docker services are running (mongo, redis, elasticsearch).
```

---

## Common local development commands

### 1 — Start required Docker services

Workarea requires **MongoDB**, **Redis**, and **Elasticsearch**.

```bash
MONGODB_VERSION=4.0 \
REDIS_VERSION=6.2 \
ELASTICSEARCH_VERSION=6.8.23 \
docker compose up -d

# Verify all three services are healthy
script/docker_services_health
```

> See [WA-CI-008](wa-ci-008-local-build-gate.md) for troubleshooting tips (stale volumes, port conflicts, etc.).

### 2 — RuboCop (diff-only vs `origin/next`)

Only lint files you actually changed:

```bash
git fetch origin next

files=$(git diff --name-only --diff-filter=ACMRT origin/next...HEAD -- '*.rb')
[ -n "$files" ] && bundle exec rubocop $files || echo "No Ruby changes vs origin/next"
```

### 3 — Run targeted engine tests

Run only the suites that match the engines you touched:

```bash
# Individual engines
bin/rails workarea:test:core
bin/rails workarea:test:admin
bin/rails workarea:test:storefront
bin/rails workarea:test:testing

# Everything
bin/rails workarea:test
```

Auto-detect which suites to run based on changed paths:

```bash
git fetch origin next
changed=$(git diff --name-only --diff-filter=ACMRT origin/next...HEAD)

run() { echo "\n==> $*"; "$@"; }

echo "$changed" | grep -q '^core/'        && run bin/rails workarea:test:core
echo "$changed" | grep -q '^admin/'       && run bin/rails workarea:test:admin
echo "$changed" | grep -q '^storefront/'  && run bin/rails workarea:test:storefront
echo "$changed" | grep -q '^testing/'     && run bin/rails workarea:test:testing
```

### 4 — Boot smoke (default appraisal)

Quickly verify the default stack boots before running the full suite:

```bash
script/default_appraisal_boot_smoke
# PASS: default appraisal booted successfully (RAILS_ENV=test)
```

### 5 — Clean stale test artifacts

```bash
script/clean
```

---

## Verification docs in this directory

| Doc | Covers |
|-----|--------|
| [wa-ci-008-local-build-gate.md](wa-ci-008-local-build-gate.md) | Full local build-gate workflow: Docker startup, RuboCop diff, targeted engine tests. **Start here for a complete pre-PR checklist.** |
| [wa-verify-003-load-defaults-audit.md](wa-verify-003-load-defaults-audit.md) | Audit of `config.load_defaults` behavioral flags for the Rails 7 migration. |
| [wa-verify-004-perf-baseline.md](wa-verify-004-perf-baseline.md) | Post-Rails-7 performance baseline — test-suite timing and environment snapshot. |
| [wa-verify-031-default-appraisal-deprecations.md](wa-verify-031-default-appraisal-deprecations.md) | Audit of Rails deprecation warnings in the default (Rails 6.1) appraisal. |
| [wa-verify-058-zeitwerk-check.md](wa-verify-058-zeitwerk-check.md) | Zeitwerk autoloading compatibility audit for the Rails 7 migration. |

---

*For the full CI pipeline context see [WA-CI-008](wa-ci-008-local-build-gate.md).*
