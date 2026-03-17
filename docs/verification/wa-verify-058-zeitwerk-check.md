# WA-VERIFY-058 — Zeitwerk Autoload Check

Closes #1023

## Purpose

Provide a single, runnable script that verifies Zeitwerk autoloading is healthy
across all three Workarea engines (`core`, `admin`, `storefront`) before a
contributor pushes their branch.

Run it any time you:

- Add, remove, or rename a file under any `app/` directory
- Modify `autoload_paths` or `eager_load_paths` in an engine initializer
- Add a new Rails engine or mountable concern
- Upgrade Zeitwerk or Rails

## Script

```
scripts/verify-zeitwerk.sh
```

### Usage

```sh
# Check all three engines (recommended pre-push)
./scripts/verify-zeitwerk.sh

# Check a single engine
./scripts/verify-zeitwerk.sh core
./scripts/verify-zeitwerk.sh admin
./scripts/verify-zeitwerk.sh storefront
```

### Requirements

| Requirement | Notes |
|-------------|-------|
| Ruby 2.7.8 via rbenv | `rbenv install 2.7.8` |
| MongoDB running | `docker compose up -d mongo` |
| `bundle install` done | At repo root |

### Exit codes

| Code | Meaning |
|------|---------|
| `0` | All checked engines passed |
| `1` | One or more engines failed |

## How it works

Zeitwerk's `check` task must run from inside each engine directory so the
engine's `bin/rails` wrapper is available.  The script:

1. Sets up rbenv for Ruby 2.7.8
2. Iterates over each engine (`core`, `admin`, `storefront`)
3. `cd`s into the engine directory and runs:
   ```sh
   BUNDLE_GEMFILE=<repo-root>/Gemfile \
   RAILS_ENV=test \
     bundle exec bin/rails zeitwerk:check
   ```
4. Parses output for `All is good!` (Rails' canonical success string)
5. Prints a colour-coded pass/fail summary with actionable failure output

## Sample output

```
────────────────────────────────────────────────────────────────
[zeitwerk] Workarea Zeitwerk Autoload Check
[zeitwerk] Ruby target : 2.7.8
[zeitwerk] Engines     : core admin storefront
[zeitwerk] Repo root   : /path/to/workarea
────────────────────────────────────────────────────────────────
[zeitwerk] Ruby 2.7.8p225 (2023-03-30 revision 1f4d455848) [arm64-darwin24]
[zeitwerk] Checking core …
  ✓ PASS  core: Zeitwerk OK

[zeitwerk] Checking admin …
  ✓ PASS  admin: Zeitwerk OK

[zeitwerk] Checking storefront …
  ✓ PASS  storefront: Zeitwerk OK

────────────────────────────────────────────────────────────────
  ✓ PASS  All 3 engine(s) passed Zeitwerk check.

  You're good to push. 🎉
────────────────────────────────────────────────────────────────
```

## Related docs

- [`docs/rails7-migration-patterns/zeitwerk-notes.md`](../rails7-migration-patterns/zeitwerk-notes.md) — Naming conventions, edge cases
- [`docs/verification-index.md`](../verification-index.md) — Full index of verification scripts
- [`docs/verification/wa-ci-008-local-build-gate.md`](wa-ci-008-local-build-gate.md) — Full CI gate checklist
