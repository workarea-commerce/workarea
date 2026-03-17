# Sidekiq Worker Error Handling — WA-VERIFY-075
**Date:** 2026-03-17  
**Issue:** #1052  
**Branch:** `issue-1052-sidekiq-worker-error-handling`

---

## 1. Workers Found (50 total)

All files matched by `grep -r 'include Sidekiq::Worker' --include='*.rb' -l .` (excluding
vendor/gemfiles directories):

| Worker | Path |
|--------|------|
| IndexProductChildren | `core/app/workers/workarea/index_product_children.rb` |
| OrderReminder | `core/app/workers/workarea/order_reminder.rb` |
| SendRefundEmail | `core/app/workers/workarea/send_refund_email.rb` |
| CleanInventoryTransactions | `core/app/workers/workarea/clean_inventory_transactions.rb` |
| IndexSearchCustomizations | `core/app/workers/workarea/index_search_customizations.rb` |
| IndexProduct | `core/app/workers/workarea/index_product.rb` |
| PublishRelease | `core/app/workers/workarea/publish_release.rb` |
| CleanProductRecommendations | `core/app/workers/workarea/clean_product_recommendations.rb` |
| ProcessSearchRecommendations | `core/app/workers/workarea/process_search_recommendations.rb` |
| ProcessDirectUpload | `core/app/workers/workarea/process_direct_upload.rb` |
| BulkIndexAdmin | `core/app/workers/workarea/bulk_index_admin.rb` |
| IndexHelp | `core/app/workers/workarea/index_help.rb` |
| KeepProductIndexFresh | `core/app/workers/workarea/keep_product_index_fresh.rb` |
| IndexPaymentTransactions | `core/app/workers/workarea/index_payment_transactions.rb` |
| GenerateContentMetadata | `core/app/workers/workarea/generate_content_metadata.rb` |
| DeactivateStaleDiscounts | `core/app/workers/workarea/deactivate_stale_discounts.rb` |
| GenerateSitemaps | `core/app/workers/workarea/generate_sitemaps.rb` |
| ProcessProductRecommendations | `core/app/workers/workarea/process_product_recommendations.rb` |
| UpdateEmail | `core/app/workers/workarea/update_email.rb` |
| MarkDiscountsAsRedeemed | `core/app/workers/workarea/mark_discounts_as_redeemed.rb` |
| SaveOrderMetrics | `core/app/workers/workarea/save_order_metrics.rb` |
| RedirectNavigableSlugs | `core/app/workers/workarea/redirect_navigable_slugs.rb` |
| BulkIndexProducts | `core/app/workers/workarea/bulk_index_products.rb` |
| BustNavigationCache | `core/app/workers/workarea/bust_navigation_cache.rb` |
| GenerateInsights | `core/app/workers/workarea/generate_insights.rb` |
| BulkIndexSearches | `core/app/workers/workarea/bulk_index_searches.rb` |
| SaveOrderCancellationMetrics | `core/app/workers/workarea/save_order_cancellation_metrics.rb` |
| BuildReleaseUndoChangesets | `core/app/workers/workarea/build_release_undo_changesets.rb` |
| IndexFulfillmentChanges | `core/app/workers/workarea/index_fulfillment_changes.rb` |
| IndexReleaseScheduleChange | `core/app/workers/workarea/index_release_schedule_change.rb` |
| CleanOrders | `core/app/workers/workarea/clean_orders.rb` |
| ProcessImport | `core/app/workers/workarea/process_import.rb` |
| SaveUserOrderDetails | `core/app/workers/workarea/save_user_order_details.rb` |
| IndexSkus | `core/app/workers/workarea/index_skus.rb` |
| PublishBulkAction | `core/app/workers/workarea/publish_bulk_action.rb` |
| GeneratePromoCodes | `core/app/workers/workarea/generate_promo_codes.rb` |
| SynchronizeUserMetrics | `core/app/workers/workarea/synchronize_user_metrics.rb` |
| ProcessReportsExport | `core/app/workers/workarea/process_reports_export.rb` |
| BustSkuCache | `core/app/workers/workarea/bust_sku_cache.rb` |
| IndexProductRule | `core/app/workers/workarea/index_product_rule.rb` |
| IndexCategorization | `core/app/workers/workarea/index_categorization.rb` |
| IndexCategory | `core/app/workers/workarea/index_category.rb` |
| VerifyScheduledReleases | `core/app/workers/workarea/verify_scheduled_releases.rb` |
| IndexAdminSearch | `core/app/workers/workarea/index_admin_search.rb` |
| UpdateElasticsearchSettings | `core/app/workers/workarea/update_elasticsearch_settings.rb` |
| IndexCategoryChanges | `core/app/workers/workarea/index_category_changes.rb` |
| IndexPage | `core/app/workers/workarea/index_page.rb` |
| ProcessExport | `core/app/workers/workarea/process_export.rb` |
| StatusReporter | `core/app/workers/workarea/status_reporter.rb` |
| IndexAdminSearch (inline perform) | `core/app/workers/workarea/index_admin_search.rb` |

---

## 2. Rescue Patterns Reviewed

All rescue patterns found in `core/app/workers/`:

```
core/app/workers/workarea/index_product_children.rb:18:      product = Catalog::Product.find(id) rescue nil
core/app/workers/workarea/send_refund_email.rb:17:    rescue Mongoid::Errors::DocumentNotFound
core/app/workers/workarea/index_product.rb:21:    rescue Mongoid::Errors::DocumentNotFound
core/app/workers/workarea/publish_release.rb:15:    rescue Mongoid::Errors::DocumentNotFound
core/app/workers/workarea/index_help.rb:13:      if article = Help::Article.find(id) rescue nil
core/app/workers/workarea/index_payment_transactions.rb:18:      order = Order.find(order_id) rescue nil
core/app/workers/workarea/update_email.rb:28:      old_metrics = Metrics::User.find(old_email) rescue nil
core/app/workers/workarea/mark_discounts_as_redeemed.rb:14:    rescue Mongoid::Errors::DocumentNotFound
core/app/workers/workarea/save_order_metrics.rb:41:    rescue Mongoid::Errors::DocumentNotFound
core/app/workers/workarea/bust_navigation_cache.rb:18:    rescue Mongoid::Errors::DocumentNotFound
core/app/workers/workarea/index_fulfillment_changes.rb:14:      order = Order.find(order_id) rescue nil
core/app/workers/workarea/save_user_order_details.rb:18:    rescue Mongoid::Errors::DocumentNotFound
core/app/workers/workarea/generate_promo_codes.rb:12:    rescue Mongoid::Errors::DocumentNotFound
core/app/workers/workarea/synchronize_user_metrics.rb:36:    rescue Mongoid::Errors::DocumentNotFound
core/app/workers/workarea/index_product_rule.rb:22:    rescue Mongoid::Errors::DocumentNotFound
core/app/workers/workarea/index_categorization.rb:20:    rescue Mongoid::Errors::DocumentNotFound
core/app/workers/workarea/index_category.rb:16:    rescue Mongoid::Errors::DocumentNotFound
core/app/workers/workarea/index_admin_search.rb:38:        search_model.try(:destroy) rescue nil
core/app/workers/workarea/index_category_changes.rb:38:          rescue
core/app/workers/workarea/index_page.rb:16:    rescue Mongoid::Errors::DocumentNotFound
```

### Pattern Classification

#### ✅ ACCEPTABLE — Specific exception types

The majority of workers use one of two safe patterns:

1. **`rescue Mongoid::Errors::DocumentNotFound`** — Used in 9 workers:
   - `send_refund_email.rb`, `index_product.rb`, `publish_release.rb`,
     `mark_discounts_as_redeemed.rb`, `save_order_metrics.rb`, `bust_navigation_cache.rb`,
     `save_user_order_details.rb`, `generate_promo_codes.rb`, `synchronize_user_metrics.rb`,
     `index_product_rule.rb`, `index_categorization.rb`, `index_category.rb`, `index_page.rb`
   - These are appropriate: the document legitimately may not exist by the time the
     worker runs (race condition / deleted in transit). The job should be a no-op, not
     retried.

2. **Inline `rescue nil` on `.find()`** — Used in 5 workers:
   - `index_product_children.rb`, `index_help.rb`, `index_payment_transactions.rb`,
     `update_email.rb`, `index_fulfillment_changes.rb`
   - Semantically equivalent to `rescue Mongoid::Errors::DocumentNotFound => nil`.
     Acceptable for the same reason as above — tolerates document disappearance.

3. **`search_model.try(:destroy) rescue nil`** in `index_admin_search.rb`
   - Limited in scope, with an inline comment: `# It's OK if it doesn't exist`
   - This is a bare `rescue nil` on a single expression; technically catches `Exception`
     but the risk surface is narrow (one `destroy` call, intentionally swallowed).
     Low priority but worth noting.

#### ⚠️ FLAGGED — Bare `rescue` (rescues `Exception`, not `StandardError`)

**`core/app/workers/workarea/index_category_changes.rb` line 38:**

```ruby
Catalog::Product.in(id: ids).each do |product|
  begin
    IndexProduct.perform(product)
  rescue
    IndexProduct.perform_async(product.id)
  end
end
```

**Problem:** A bare `rescue` in Ruby rescues `Exception` (the root class), not
`StandardError`. This means it will intercept:
- `SignalException` (e.g., `SIGTERM` used by Sidekiq for graceful shutdown)
- `Interrupt` (Ctrl-C)
- `NoMemoryError`, `SystemExit`, `ScriptError`

This suppresses the very signals that Sidekiq uses for job termination/retry during
graceful shutdown. A `SIGTERM` that should cause the job to exit cleanly and be
requeued by Sidekiq will instead be swallowed, and the worker will fall back to
`perform_async` on the product — masking the shutdown entirely.

**Recommended fix:**
```ruby
begin
  IndexProduct.perform(product)
rescue StandardError
  IndexProduct.perform_async(product.id)
end
```

This correctly limits the rescue to application-level errors while allowing VM-level
signals to propagate.

---

## 3. Test Results Under Rails 7.1 Appraisal

### Rails 7.1

**Result: Could not run — dependency resolution failure.**

```
Could not find compatible versions

Because every version of workarea-core depends on mongoid ~> 7.4
  and mongoid >= 7.3.4, < 8.0.7 depends on activemodel >= 5.1, < 7.1, != 7.0.0,
  every version of workarea-core requires activemodel >= 5.1, < 7.1, != 7.0.0.
And because rails >= 7.1.5.1, < 7.1.5.2 depends on activemodel = 7.1.5.1,
every version of workarea-core is incompatible with rails >= 7.1.5.1, < 7.1.5.2.
```

The `rails_7_1.gemfile` already documents this in its header comment (added by a
prior investigation). Root cause: `mongoid ~> 7.4` hard-pins `activemodel < 7.1`,
which is incompatible with Rails 7.1's `activemodel 7.1.x`. Resolution requires
either upgrading to Mongoid 8+ or waiting for a mongoid release that relaxes the
upper bound.

### Rails 7.0

**Result: Could not run — app boot failure.**

```
NameError: uninitialized constant Workarea::EnforceHostMiddleware
  from core/config/initializers/10_rack_middleware.rb:56
```

The test suite cannot boot the dummy Rails app under Rails 7.0 due to a missing
constant (`EnforceHostMiddleware`) that is referenced in an initializer but not
defined in the gem. This is a pre-existing boot failure unrelated to worker error
handling. Tests could not be executed.

---

## 4. Workers Flagged for Non-Retryable / Overly-Broad Error Handling

| Worker | Line | Issue | Severity |
|--------|------|-------|----------|
| `IndexCategoryChanges` | 38 | Bare `rescue` (rescues `Exception`) in inline product re-index fallback — suppresses `SIGTERM` and prevents Sidekiq graceful shutdown | **High** |
| `IndexAdminSearch` | 38 | `rescue nil` on single `.destroy` call (bare, technically catches `Exception`) | Low |

### Recommendation

Fix `index_category_changes.rb` line 38: change bare `rescue` → `rescue StandardError`.
This is a correctness issue, not just style — it can mask graceful shutdowns and prevent
Sidekiq from properly requeueing jobs during deploys.

The `rescue nil` on `search_model.try(:destroy)` in `index_admin_search.rb` is lower
priority (single expression, deliberate intent, commented), but could be tightened to
`rescue Mongoid::Errors::DocumentNotFound => nil` for clarity.

---

## 5. Summary

- **50 Sidekiq workers** identified across `core/app/workers/workarea/`
- **20 rescue patterns** found in worker files
- **18** are acceptable (specific exception types or intentional nil-rescue on `.find`)
- **1** is flagged high (`IndexCategoryChanges` bare `rescue` → suppresses `SIGTERM`)
- **1** is flagged low (`IndexAdminSearch` bare `rescue nil` on single destroy)
- **Test execution blocked** on both Rails 7.0 (boot failure) and Rails 7.1
  (dependency conflict); neither is caused by the worker error handling itself
