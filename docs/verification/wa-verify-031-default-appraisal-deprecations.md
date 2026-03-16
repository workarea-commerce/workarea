# WA-VERIFY-031 — Default-Appraisal Deprecation Warning Snapshot

Closes #879

## Purpose

Capture `DEPRECATION WARNING:` lines emitted by ActiveSupport when the default
appraisal (root `Gemfile.lock`) boots under Ruby 3.2.7.  The output is a stable
log artifact that can be committed or diffed over time to track warning churn.

---

## How to run

### Prerequisites

```sh
# Install Ruby 3.2.7 via rbenv (skip if already installed)
export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init - zsh)"          # or bash
rbenv install 3.2.7

# The repo's .ruby-version pins to 3.2.7; rbenv picks this up automatically.
```

### Execute

```sh
cd /path/to/workarea
./script/default_appraisal_deprecations
```

The script uses the root `Gemfile` / `Gemfile.lock` (the **default appraisal**).
It does **not** require `bin/rails` at the repo root — it boots each engine's
`test/dummy/config/environment.rb` directly via `bundle exec ruby`.

### Environment variables (optional overrides)

| Variable | Default | Purpose |
|---|---|---|
| `RAILS_ENV` | `test` | Rails environment to boot under |
| `LOG_FILE` | `log/default_appraisal_deprecations.log` | Override log output path |

---

## Where to look for output

### Terminal

Lines prefixed with `[DEPRECATION] <engine>:` are written to stdout as they are
found.  Warnings do **not** cause a non-zero exit — only boot errors do.

### Log file

```
log/default_appraisal_deprecations.log
```

The log is appended on each run with a timestamped header so successive runs are
distinguishable.  Sample format:

```
# default_appraisal_deprecations — run started at 2026-03-16T10:00:00Z
# RAILS_ENV=test
# Ruby: ruby 3.2.7 (2024-05-16 revision …) [arm64-darwin24]
# Bundler: Bundler version 2.5.x
#
# core: 2 DEPRECATION WARNING line(s)
[DEPRECATION] core: DEPRECATION WARNING: BigDecimal() is deprecated; …
[DEPRECATION] core: DEPRECATION WARNING: …
# admin: no DEPRECATION WARNING lines
# storefront: no DEPRECATION WARNING lines
#
# run completed at 2026-03-16T10:00:12Z
```

---

## Exit codes

| Code | Meaning |
|---|---|
| `0` | All engines checked (warnings are informational; they do not fail the run) |
| `1` | One or more engines failed to boot |

---

## Engines checked

| Engine | Boot surface |
|---|---|
| `core` | `core/test/dummy/config/environment.rb` |
| `admin` | `admin/test/dummy/config/environment.rb` |
| `storefront` | `storefront/test/dummy/config/environment.rb` |

---

## Integration with `script/verify`

You can add this check to `script/verify`'s registry at any time:

```
default-appraisal-deprecations|script/default_appraisal_deprecations|Capture DEPRECATION WARNING lines from the default appraisal stack
```

---

## See also

- [`script/default_appraisal_boot_smoke`](../../script/default_appraisal_boot_smoke) — quick boot smoke test
- [`script/default_appraisal_zeitwerk_check`](../../script/default_appraisal_zeitwerk_check) — Zeitwerk autoload check
- [WA-VERIFY-003](wa-verify-003-load-defaults-audit.md) — `config.load_defaults` audit
