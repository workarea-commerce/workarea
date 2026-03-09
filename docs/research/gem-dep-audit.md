# Gem Dependency Audit — WA-NEW-032

**Date:** 2026-03-01  
**Branch:** `wa-new-032-gem-dep-audit`  
**Gemspec:** `core/workarea-core.gemspec`  
**Ruby baseline:** 3.2.7  
**Rails baseline:** 6.1.x  

Note: Ruby 2.7.8 was historically used for Rails 6.1-era Workarea development, but Ruby 2.7 is end-of-life. Use Ruby 2.7.8 only when working on legacy branches that still require it.

---

## Summary

All dependencies in `core/workarea-core.gemspec` were audited for overly tight version
constraints that would prevent patch-level updates or block eventual Rails 7 / Ruby 3.x
upgrades. Two categories of changes were made:

1. **Patch pins loosened to minor pins** — e.g. `~> 1.2.1` → `~> 1.2`. This allows
   patch-level updates to resolve without gemspec changes.
2. **Rails 7 / Ruby 3 hard blockers** — documented below; NOT changed here because they
   require deeper migration work.

`bundle install` passes after all changes.

---

## Skipped (covered by other open PRs)

| Gem | Reason |
|-----|--------|
| `rails` | PR #697 (wa-rails7-001) updates to `>= 6.1, < 7.2` |
| `dragonfly` | PR #705 (wa-new-034) updates to `~> 1.4.1` |
| `loofah` | PR #708 (wa-new-036) updates to `~> 2.25.0` |
| `rails-html-sanitizer` | PR #708 (wa-new-036) updates to `~> 1.7.0` |

---

## Changes Made (patch → minor loosening)

| Gem | Before | After | Notes |
|-----|--------|-------|-------|
| `mongoid` | `~> 7.4.0` | `~> 7.4` | Allows patch updates within 7.4.x |
| `bcrypt` | `~> 3.1.10` | `~> 3.1` | Stable API, safe to loosen |
| `money-rails` | `~> 1.13.0` | `~> 1.13` | Patch loosening only |
| `mongoid-document_path` | `~> 0.2.0` | `~> 0.2` | Small gem, stable |
| `mongoid-tree` | `~> 2.1.0` | `~> 2.1` | Patch loosening |
| `mongoid-sample` | `~> 0.1.0` | `~> 0.1` | Patch loosening |
| `mongoid-encrypted` | `~> 1.0.0` | `~> 1.0` | Patch loosening |
| `elasticsearch` | `~> 5.0.1` | `~> 5.0` | Patch loosening; major blocker noted below |
| `kaminari` | `~> 1.2.1` | `~> 1.2` | Patch loosening |
| `kaminari-mongoid` | `~> 1.0.0` | `~> 1.0` | Patch loosening |
| `geocoder` | `~> 1.6.3` | `~> 1.6` | Patch loosening |
| `redis-rack-cache` | `~> 2.2.0` | `~> 2.2` | Patch loosening |
| `easymon` | `~> 1.4.0` | `~> 1.4` | Patch loosening |
| `image_optim` | `~> 0.28.0` | `~> 0.28` | Patch loosening |
| `image_optim_pack` | `~> 0.7.0` | `~> 0.7` | Patch loosening |
| `faker` | `~> 2.15.0` | `~> 2.15` | Patch loosening |
| `fastimage` | `~> 2.2.0` | `~> 2.2` | Patch loosening |
| `rack-timeout` | `~> 0.6.0` | `~> 0.6` | Patch loosening |
| `sassc-rails` | `~> 2.1.0` | `~> 2.1` | Patch loosening |
| `ruby-stemmer` | `~> 3.0.0` | `~> 3.0` | Patch loosening |
| `sprockets-rails` | `~> 3.2.0` | `~> 3.2` | Patch loosening; major blocker noted below |
| `sprockets` | `~> 3.7.2` | `~> 3.7` | Patch loosening; major blocker noted below |
| `predictor` | `~> 2.3.0` | `~> 2.3` | Patch loosening |
| `js-routes` | `~> 1.4.0` | `~> 1.4` | Patch loosening |
| `mongoid-active_merchant` | `~> 0.2.0` | `~> 0.2` | Patch loosening |
| `normalize-rails` | `~> 8.0.1` | `~> 8.0` | Patch loosening |
| `featurejs_rails` | `~> 1.0.1` | `~> 1.0` | Patch loosening |
| `webcomponentsjs-rails` | `~> 0.7.12` | `~> 0.7` | Patch loosening |
| `strftime-rails` | `~> 0.9.2` | `~> 0.9` | Patch loosening |
| `i18n-js` | `~> 3.8.0` | `~> 3.8` | Patch loosening |
| `local_time` | `~> 2.1.0` | `~> 2.1` | Patch loosening |
| `lodash-rails` | `~> 4.17.4` | `~> 4.17` | Patch loosening |
| `jquery-rails` | `~> 4.4.0` | `~> 4.4` | Patch loosening |
| `jquery-ui-rails` | `~> 6.0.1` | `~> 6.0` | Patch loosening |
| `tooltipster-rails` | `~> 4.2.0` | `~> 4.2` | Patch loosening |
| `select2-rails` | `~> 4.0.3` | `~> 4.0` | Patch loosening |
| `rack-attack` | `~> 6.3.1` | `~> 6.3` | Patch loosening |
| `redcarpet` | `~> 3.5.1, >= 3.5.1` | `~> 3.5` | Simplified constraint |
| `jquery-livetype-rails` | `~> 0.1.0` | `~> 0.1` | Patch loosening |
| `jquery-unique-clone-rails` | `~> 1.0.0` | `~> 1.0` | Patch loosening |
| `avalanche-rails` | `~> 1.2.0` | `~> 1.2` | Patch loosening |
| `inline_svg` | `~> 1.7.0` | `~> 1.7` | Patch loosening |
| `haml` | `~> 5.2.0` | `~> 5.2` | Patch loosening; major blocker noted below |
| `ejs` | `~> 1.1.1` | `~> 1.1` | Patch loosening |
| `jbuilder` | `~> 2.10.0` | `~> 2.10` | Patch loosening |
| `tribute` | `~> 3.6.0.0` | `~> 3.6` | Patch loosening |
| `turbolinks` | `~> 5.2.0` | `~> 5.2` | Patch loosening |
| `jquery-validation-rails` | `~> 1.19.0` | `~> 1.19` | Patch loosening |
| `minitest` | `~> 5.14.0` | `~> 5.14` | Patch loosening |
| `countries` | `~> 3.0.0` | `~> 3.0` | Patch loosening |
| `waypoints_rails` | `~> 4.0.1` | `~> 4.0` | Patch loosening |
| `icalendar` | `~> 2.7.0` | `~> 2.7` | Patch loosening |
| `premailer-rails` | `~> 1.11.0` | `~> 1.11` | Patch loosening |
| `json-streamer` | `~> 2.1.0` | `~> 2.1` | Patch loosening |
| `spectrum-rails` | `~> 1.8.0` | `~> 1.8` | Patch loosening |
| `dragonfly-s3_data_store` | `~> 1.3.0` | `~> 1.3` | Patch loosening |
| `referer-parser` | `~> 0.3.0` | `~> 0.3` | Patch loosening |
| `serviceworker-rails` | `~> 0.6.0` | `~> 0.6` | Patch loosening |
| `chartkick` | `~> 3.4.0` | `~> 3.4` | Patch loosening |
| `browser` | `~> 5.3.0` | `~> 5.3` | Patch loosening |
| `dragonfly_libvips` | `~> 2.4.2` | `~> 2.4` | Patch loosening |
| `sitemap_generator` | `~> 6.1.2` | `~> 6.1` | Patch loosening |
| `recaptcha` | `~> 5.6.0` | `~> 5.6` | Patch loosening |
| `active_utils` | `~> 3.3.1` | `~> 3.3` | Patch loosening |

---

## Unchanged (already appropriately constrained)

| Gem | Constraint | Reason |
|-----|-----------|--------|
| `bundler` | `>= 1.8.0` | Already loose |
| `mongoid-audit_log` | `>= 0.6.0` | Already loose |
| `faraday` | `>= 2.2, < 3` | Already range-constrained |
| `faraday-net_http` | `~> 3.0` | Already minor-pinned |
| `activemerchant` | `~> 1.52` | Already minor-pinned |
| `sidekiq` | `~> 7.0` | Already minor-pinned |
| `sidekiq-cron` | `~> 1.12` | Already minor-pinned |
| `sidekiq-unique-jobs` | `~> 8.0` | Already minor-pinned |
| `sidekiq-throttled` | `~> 1.5` | Already minor-pinned |
| `autoprefixer-rails` | `9.8.5` | Exact pin intentional (deprecation warnings in newer) |
| `wysihtml-rails` | `~> 0.6.0.beta2` | Pre-release — keep exact pre-release pin |
| `rails-decorators` | `~> 1.0.0.pre` | Pre-release — keep exact pre-release pin |
| `puma` | `>= 4.3.1` | Already loose |
| `rack` | `>= 2.1.4` | Already loose |
| `measured` | `>= 2.0` | Already loose |

---

## Rails 7 / Ruby 3.x Hard Blockers

These gems require major version bumps and deeper migration work before Rails 7 / Ruby 3.x
can be adopted. They are NOT changed in this PR — only documented here.

### 1. `mongoid ~> 7.4` → needs `~> 8.0`
- Mongoid 8 officially supports Rails 7. Mongoid 7 does not support Rails 7 ActiveRecord/AR
  integration changes.
- Migration involves schema/query API changes and `mongoid.yml` updates.
- **Severity:** CRITICAL blocker for Rails 7

### 2. `sprockets ~> 3.7` → needs `~> 4.0` (with `sprockets-rails ~> 3.4`)
- Sprockets 4 changes the asset manifest format and requires `manifest.js`.
- Sprockets 3 does not support Rails 7's asset pipeline expectations.
- Migration: add `app/assets/config/manifest.js`, update `link_tree`/`link` directives.
- **Severity:** CRITICAL blocker for Rails 7

### 3. `elasticsearch ~> 5.0` → needs `~> 7.0` or `~> 8.0`
- The v5 client is not compatible with Elasticsearch 7+ server or modern Rails.
- Migrating to the official `elasticsearch` v7/v8 client involves renamed classes and new
  transport configuration.
- **Severity:** HIGH — blocks ES server upgrades and indirectly affects Rails 7 compat

### 4. `haml ~> 5.2` → may need `~> 6.0`
- Haml 6 removed deprecated APIs used in older templates. Ruby 3.x compatibility improved
  in haml 6.
- Migration: audit templates for removed `html_escape` / `find_and_preserve` usage.
- **Severity:** MEDIUM — Ruby 3.x compat concern; run haml-lint before bumping

### 5. `sprockets-rails ~> 3.2` → needs `~> 3.4`
- sprockets-rails 3.4 is the version that bundles Sprockets 4 support.
- Tied to the Sprockets 4 upgrade above.
- **Severity:** Tied to Sprockets 4 upgrade

### 6. `countries ~> 3.0`
- Countries gem 4.x changed internal data format. Upgrading may require template/model updates.
- **Severity:** LOW-MEDIUM — evaluate before upgrading

---

## Verification

```
bundle install   # ✅ passes — "Bundle complete! 11 Gemfile dependencies, 220 gems now installed."
```

Test suite results captured in CI. See PR for test run output.
