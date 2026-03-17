# WA-VERIFY-086 — Mongoid QueryCache migration (Mongoid 8+)

## Problem
Mongoid 8 begins deprecating/renoving `Mongoid::QueryCache` (fully removed in Mongoid 9).
Workarea referenced `Mongoid::QueryCache` directly in a few places.

## Change
Replaced all core call sites with the mongo Ruby driver equivalent:
- `Mongoid::QueryCache.*` → `Mongo::QueryCache.*`
- `Mongoid::QueryCache::Middleware` → `Mongo::QueryCache::Middleware`

This keeps the per-request query cache middleware in place and preserves existing
behavior where Workarea explicitly clears or bypasses the query cache.

## Files
- core/app/queries/workarea/admin_search_query_wrapper.rb
- core/app/models/workarea/releasable.rb
- core/config/initializers/10_rack_middleware.rb
- core/test/middleware/workarea/rack_middleware_stack_test.rb
- core/test/models/workarea/releasable_test.rb

## Client impact
None expected.
