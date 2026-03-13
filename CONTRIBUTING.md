## How to contribute to Workarea

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
for the full inventory of accepted warnings and their owners.

Thanks!

The Workarea Core Team
