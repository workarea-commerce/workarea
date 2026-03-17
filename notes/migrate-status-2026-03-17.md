# WA-VERIFY-072 — Migration status verification (next)

Date: 2026-03-17
Branch: `wa-verify-072-migrate-status` (off `next`)

## Environment
- Repo uses Ruby `3.2.7` (`.ruby-version`)
- Bundler: `bundle install` succeeded (vendor/bundle)

## What I checked
### Rails / Rake tasks
At repo root, `bundle exec rake -T | grep -i migrat` found **no** generic migration/status tasks.

Within the Rails dummy app used for testing:
- `core/test/dummy`
- `admin/test/dummy`

I listed tasks via:

```sh
cd core/test/dummy
bin/rails -T | egrep -i "migrat|mongoid"
```

Available DB-related tasks are Mongoid-focused (indexes, drop/purge, etc.). Example output includes:
- `db:mongoid:create_indexes`
- `db:mongoid:drop`
- `db:mongoid:purge`
- `db:mongoid:remove_indexes`

Workarea also provides a data-migration task:
- `workarea:migrate:v3_5`

### `db:migrate:status`
Attempting to run migration status in the dummy apps:

```sh
bin/rails db:migrate:status
```

Result:
- **Error**: `Don't know how to build task 'db:migrate:status'`

This indicates Workarea (in this repo / dummy apps) is **not** using ActiveRecord migrations, and no equivalent `*:status` task is defined for Mongoid.

### Migration files
Searched for app migration directories:

```sh
find . -type d -path "*/db/migrate"
```

Result:
- No `db/migrate` directories were found in Workarea itself (only within vendored gems).

## Conclusion
**Clean / N/A for status** — On `next`, Workarea’s codebase does not define ActiveRecord migration status (`db:migrate:status`) and does not include app `db/migrate` files. Database change management appears to be via Mongoid schema/index tasks plus explicit Workarea data migration tasks (e.g., `workarea:migrate:v3_5`).
