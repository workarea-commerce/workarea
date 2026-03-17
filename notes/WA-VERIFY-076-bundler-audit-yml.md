# WA-VERIFY-076: .bundler-audit.yml configuration

## Status: Resolved

The `.bundler-audit.yml` configuration file required by PR #1047 (WA-CI-014)
exists in the repository root. It was introduced via PR #657 and extended with
documented CVE ignores in PR #708 (WA-NEW-036).

## File Format

The config uses bundler-audit's YAML ignore-list format:

```yaml
# bundler-audit configuration
# Use this file to acknowledge known advisories that cannot be fixed immediately.
# Format:
# ignore:
#   - CVE-XXXX-XXXXX  # Brief justification

ignore: []  # or list CVEs to suppress
```

## Verification

```bash
bundle exec bundler-audit check --config .bundler-audit.yml
```

Exits 0 on `next` — confirmed via CI.

## Related

- Issue #1053
- PR #1047 (WA-CI-014) — CI job that references this config
- PR #657 — original introduction of the file
- PR #1041 (issue-1032) — current documented ignore list on `next`
