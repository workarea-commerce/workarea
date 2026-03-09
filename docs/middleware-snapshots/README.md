# Middleware Stack Snapshots

Captured middleware stacks for each appraisal. These snapshots are used to verify
that the Rack middleware stack remains stable and correct across Rails versions
as part of the Workarea modernization project.

## Snapshot Files

| Appraisal | Rails Version | Snapshot |
|-----------|--------------|---------|
| default   | 6.1.x        | [default.txt](./default.txt) |
| rails_7_1 | 7.1.5.1      | [rails_7_1.txt](./rails_7_1.txt) |
| rails_7_2 | ~7.2.0       | [rails_7_2.txt](./rails_7_2.txt) |

## How to Regenerate

Run the `bin/snapshot-middleware` script from the repo root:

```bash
bin/snapshot-middleware
```

Or manually for each appraisal:

```bash
# Default (Rails 6.1) — uses rake, not rails command
bundle exec rake -f storefront/test/dummy/Rakefile middleware \
  > docs/middleware-snapshots/default.txt

# Rails 7.1
BUNDLE_GEMFILE=gemfiles/rails_7_1.gemfile bundle install
BUNDLE_GEMFILE=$(pwd)/gemfiles/rails_7_1.gemfile \
  bundle exec ruby storefront/test/dummy/bin/rails middleware \
  > docs/middleware-snapshots/rails_7_1.txt

# Rails 7.2
BUNDLE_GEMFILE=gemfiles/rails_7_2.gemfile bundle install
BUNDLE_GEMFILE=$(pwd)/gemfiles/rails_7_2.gemfile \
  bundle exec ruby storefront/test/dummy/bin/rails middleware \
  > docs/middleware-snapshots/rails_7_2.txt
```

## Prerequisites

- Ruby 3.2.7 (via rbenv)
- Docker services running: MongoDB, Redis (Elasticsearch optional for middleware check)
- All appraisal bundles installed (`bundle install` per gemfile)

## Notes

- Rails 6.1 (default appraisal) uses `rake middleware` (not `rails middleware`)
  because the `middleware` command was not available as a Rails CLI command in Rails 6.x.
- Rails 7.1 and 7.2 appraisals require `mongoid ~> 8.1` (overridden in the appraisal
  gemfiles) since Mongoid 7.4 caps `activemodel < 7.1`, preventing Rails 7.x resolution.
  Full Mongoid 8 migration is tracked in WA-RAILS7-004.
- The `rails-decorators` gem must use the `next` branch (not `master`) for Rails 7.1
  appraisals to boot correctly.
- The middleware stack is identical across all three Rails versions as of this snapshot,
  confirming no middleware regressions during the Rails 7 migration.
