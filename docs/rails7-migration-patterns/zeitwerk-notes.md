# Zeitwerk notes

This repo is a Rails engines gem, so `zeitwerk:check` is run from the dummy apps:

- `core/test/dummy`
- `admin/test/dummy`
- `storefront/test/dummy`

## Results (2026-03-04)

- `bundle exec bin/rails zeitwerk:check` ✅ (all three dummy apps)
- Production eager load ✅
  - Command used:
    - `SECRET_KEY_BASE=dummy RAILS_ENV=production bundle exec bin/rails runner 'Rails.application.eager_load!; puts "Eager load OK"'`

## Notes

- Dummy apps use Mongoid, so production environment config should not assume `config.active_record` is available.
- Middleware stack is frozen after initialization; middleware changes must be configured during boot (not in `after_initialize`).
