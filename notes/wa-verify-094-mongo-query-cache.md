# WA-VERIFY-094 — Mongo::QueryCache API / version notes

Workarea currently depends on `mongoid ~> 7.4` (see `core/workarea-core.gemspec`).
Mongoid 7.4 depends on the `mongo` Ruby driver `>= 2.10.5, < 3.0.0` (see `Gemfile.lock`).

## Query cache API

The `mongo` driver provides `Mongo::QueryCache` and `Mongo::QueryCache::Middleware` in the 2.x
series.

In the currently locked driver (`mongo 2.23.0`):

- `Mongo::QueryCache.cache { ... }` ✅
- `Mongo::QueryCache.uncached { ... }` ✅
- `Mongo::QueryCache.clear` ✅ (note: **method name is `clear`, not `clear_cache`**)
- `Mongo::QueryCache::Middleware` ✅

The middleware’s `ensure` clause calls `Mongo::QueryCache.clear`.

If Workarea ever needs a `clear_cache` entry point for the driver cache, it would need to call
`Mongo::QueryCache.clear` (or provide a compatibility alias).
