## How to contribute to Workarea

---

## Common local commands

A quick-reference for the commands contributors need day-to-day.
For full setup details see [Contribute Code](https://developer.workarea.com/articles/contribute-code.html).

### Ruby version (rbenv)

```bash
rbenv local 3.2.7   # pin the repo to Ruby 3.2.7
ruby --version      # confirm: ruby 3.2.7 (...)
```

> **Note:** lockfile regeneration (`bundle install`) always requires Ruby 3.2.7.
> The test suite also runs under 2.7.8 via CI, but 3.2.7 is the default dev version.

### Docker services — check & start

```bash
# Check port availability and current service status
script/check_service_ports
script/docker_services_status

# Start mongo, redis, and elasticsearch
script/services_up

# Stop them again
script/services_up --down
```

### Run a targeted engine test from the repo root

```bash
# Run a single test file in a specific engine component
script/test core test/models/workarea/user_test.rb

# Run the full test suite for a component
script/test core

# Run a specific test by name pattern
script/test core test/models/workarea/user_test.rb -n test_email_address
```

`script/test <component> [test_file] [minitest_options]`

### Run RuboCop (diff-only if available)

```bash
# Lint only files changed vs. the next branch (fast, recommended before pushing)
git diff origin/next --name-only --diff-filter=d | grep '\.rb$' | xargs bundle exec rubocop

# Lint the entire codebase
bundle exec rubocop

# Auto-correct safe offenses
bundle exec rubocop -a
```

### Boot smoke test (default appraisal)

Verifies the default `Gemfile.lock` stack can boot in test mode:

```bash
script/default_appraisal_boot_smoke
# PASS: default appraisal booted successfully (RAILS_ENV=test)
```

Run this before opening a PR to catch gem boot regressions early.

---

#### Did you find a bug?

* **Do not open up a GitHub issue if the bug is a security vulnerability
  in Workarea**, and instead to refer to our [security policy](https://developer.workarea.com/articles/security-policy.html).

* **Ensure the bug was not already reported** by searching on GitHub
  under [Issues](https://github.com/workarea-commerce/workarea/issues).

* If you're unable to find an open issue addressing the problem, [open a new one](https://github.com/workarea-commerce/workarea/issues/new)
  Be sure to include a **title and clear description**, as much relevant
  information as possible, and a **code sample** or an **executable test
  case** demonstrating the expected behavior that is not occurring.

* For more detailed information on submitting a bug report and creating
  an issue, check out the [Report a Bug](https://developer.workarea.com/articles/report-a-bug.html) guide.

#### Did you write a patch that fixes a bug?

* Open a new GitHub pull request with the patch.

* Ensure the PR description clearly describes the problem and solution.
  Include the relevant issue number if applicable.

* Run ShellCheck on repo scripts (CI will run this too):

  ```bash
  # macOS
  brew install shellcheck

  shellcheck script/*
  ```

  Note: some `script/*` utilities require `bash` (see their shebang).

* Before submitting, please read the [Contribute Code](https://developer.workarea.com/articles/contribute-code.html)
  guide to know more about coding conventions and benchmarks.

#### Posting GitHub comments from the CLI (safe quoting)

When posting a GitHub issue comment from your shell, be careful with content that
includes literal backticks (`` ` ``) or `${...}`.

* Backticks and `$(...)` are command substitution in many shells.
* `${...}` may be expanded by your shell (parameter expansion).

A safe pattern is to pass the comment body via STDIN using a *single-quoted*
heredoc delimiter, which prevents your shell from interpreting the content:

Note: the quotes in `<<'EOF'` are important — they prevent expansion and command substitution inside the heredoc.

````sh
gh issue comment <N> --body-file - <<'EOF'
Here is a code sample containing literal backticks and ${...}:

```ruby
puts `echo hello`
puts "${NOT_EXPANDED}"
```
EOF
````

#### Did you fix whitespace, format code, or make a purely cosmetic patch?

Changes that are purely cosmetic in nature, and do not add anything
substantial to the stability, functionality, or testability of the
Workarea platform will not be accepted. This is to prevent unnecessary
churn and additional diff-reading work for implementers who wish to
upgrade to the latest version.

#### Do you want to contribute to the Workarea documentation?

* Please read [Contribute Documentation](https://developer.workarea.com/articles/contribute-documentation.html).

#### CI failure: "gemspecs for path gems changed, but the lockfile can't be updated because frozen mode is set"

If CI reports this error your `Gemfile.lock` is stale and must be regenerated
locally before pushing. Workarea CI runs Bundler with `--frozen`; any gemspec
change requires an explicit lockfile update.

**Quick fix** (from the repo root, clean shell):

```bash
rbenv local 3.2.7   # lockfile regeneration requires Ruby 3.2.7
ruby --version      # confirm
bundle install
git add Gemfile.lock
git commit -m "docs: regenerate Gemfile.lock"
git push
```

**Common gotchas:**
- Running under Ruby 2.7.8 (the test-suite Ruby) produces the wrong lockfile —
  always use **3.2.7** for `bundle install`.
- A local `vendor/bundle` directory can mask the issue; run
  `bundle config unset path` to clear it.
- Your branch must be based on `next`; branching from the wrong base can cause
  gemspec mismatches.

For full details, see
[docs/source/articles/bundler-frozen-mode-lockfile-fix.html.md](docs/source/articles/bundler-frozen-mode-lockfile-fix.html.md).

---

#### Brakeman static analysis baseline

Workarea uses [Brakeman](https://brakemanscanner.org/) for static security
analysis.  A baseline file (`core/brakeman.baseline.json`) suppresses
pre-existing warnings so that CI only fails on **new** findings introduced by a
PR.

**If Brakeman reports a new warning in your PR:**

1. Fix the issue if you reasonably can.
2. If the warning is a confirmed false positive, or the fix belongs in a
   separate issue, add the fingerprint to `core/brakeman.baseline.json` **and**
   add a row to [`docs/security/brakeman-baseline-triage.md`](docs/security/brakeman-baseline-triage.md)
   with either a tracking-issue link or an explicit risk-acceptance rationale.
3. Never add to the baseline silently — the triage doc is the paper trail.

See [`docs/security/brakeman-baseline-triage.md`](docs/security/brakeman-baseline-triage.md)
for the full inventory of accepted warnings and their owners.  For a high-level
map of finding categories → tracking issues, see
[`docs/security/brakeman-findings.md`](docs/security/brakeman-findings.md).

#### bundler-audit dependency vulnerability scanning

Workarea uses [bundler-audit](https://github.com/rubysec/bundler-audit) to scan
gem dependencies for known CVEs on every PR and push.

**Run locally before opening a PR:**

```sh
bundle exec bundler-audit check --update --config .bundler-audit.yml
```

`--update` fetches the latest advisory database. `--config` applies the project
ignore list (`.bundler-audit.yml`) for CVEs that are blocked by an in-progress
Rails or Ruby upgrade.

**If bundler-audit reports a new vulnerability in your PR:**

1. Upgrade the affected gem if a patched version is compatible.
2. If upgrading is blocked (e.g. requires a Rails or Ruby version bump that is
   not yet landed), add the CVE or GHSA identifier to `.bundler-audit.yml` with
   a comment explaining the blocker and a link to the tracking issue.
3. Never ignore a CVE silently — always add a justification comment.

Thanks!

The Workarea Core Team
