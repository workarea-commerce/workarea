---
title: Workarea 3.0.7
excerpt: #2536
---

# Workarea 3.0.7

## Fixes Scheduled Jobs for Removed/Renamed Workers

[#2536](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2536/overview)

Workarea 3.0.7 modifies the _workarea-core/config/initializers/05\_scheduled\_jobs.rb_ initializer to remove [Sidekiq cron jobs](workers.html#sidekiq-cron-job) that reference [workers](workers.html) that were previously removed or renamed.

The change removes cron jobs for the `Workarea::UpdateDashboards` and `Workarea::Admin::StatusReporter` workers and adds a job for the `Workarea::StatusReporter` worker.

After upgrading, the removed jobs may still exist within Sidekiq as retried or scheduled jobs and will raise exceptions when Sidekiq tries to run them. You must manually clear these jobs from Sidekiq within each environment.

## Fixes Styling of Validation Messages in Storefront

[#2566](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2566/overview), [#2572](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2572/overview), [e03d11b2e0f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e03d11b2e0f607eb36d434c3f5e2b24435fec9d9)

![validation message in Storefront](images/validation-message-in-storefront.png)

Prior to 3.0.7, client-side validation messages in the Storefront are unstyled because the class value expected by the stylesheet, _value\_\_error_, isn't present in the DOM. The class value is missing in these versions because the _value_ component was dropped from the Admin in Workarea 3.0, and the Admin and Storefront share client-side validation behavior, which was updated to match the Admin for Workarea 3.0.

To fix this issue, Workarea 3.0.7 removes the shared validation behavior from Core and adds validation behavior to the Admin and Storefront engines directly. The changes are summarized below.

- The configuration value `WORKAREA.config.forms.errorLabelClasses` is removed from the Core config file, _workarea/core/config.js_, and added separately to the Admin and Storefront config files, _workarea/admin/config.js.erb_ and _workarea/storefront/config.js.erb_.
- The `WORKAREA.forms` JavaScript module is removed from Core, _workarea/core/modules/forms.js_, and added separately to Admin and Storefront, _workarea/admin/modules/forms.js_ and _workarea/storefront/modules/forms.js_.
- The Admin and Storefront JavaScript manifests, _workarea/admin/application.js.erb_ and _workarea/storefront/application.js.erb_, are modified to reflect the above changes.
- The Storefront application layout, _workarea/storefront/application.html.haml_, is modified to add missing _value_ components needed to style validation messages for the search and email signup forms.

If your application is overriding any of the above assets, update your copies as needed to fix validation styling in the Storefront.

## Improves UI for Backordered Until Field

[#2567](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2567/overview)

Workarea 3.0.7 modifies the _workarea/admin/inventory\_skus/new.html.haml_ and _workarea/admin/bulk\_action\_product\_edits/edit.html.haml_ Admin views, adding a `data-datepicker-field` attribute to the `backordered_until` field (named _Backorder Ship Date_ in the English translation of the Admin). This change provides a calendar UI for this field when focused.

![calendar for backordered until field](images/calendar-for-backordered-until-field.png)

This change also modifies the _workarea/admin/inventory\_skus/\_cards.html.haml_ Admin partial to output a `backordered_until` value for an inventory SKU when present.

![backordered until output on inventory sku card](images/backordered-until-output-on-inventory-sku-card.png)

If your application is overriding any of these views, apply the changes manually to benefit from these improvements.

## Fixes Display of Admin Filters when Wrapping

[#2568](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2568/overview)

Workarea 3.0.7 modifies the _workarea/admin/components/\_browsing\_controls.scss_ Admin stylesheet to fix the display of Admin filters when they wrap to a second line.

![filters wrapping to second line in Admin](images/filters-wrapping-to-second-line-in-admin.png)

If your application is overriding this stylesheet, you'll need to apply this patch manually to your copy.

## Fixes Duplicate ID Values in Admin Content Editing HTML

[#2544](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2544/overview)

Workarea 3.0.7 modifies the following Admin partials to fix duplicate ID values in the HTML rendered for the content editing page.

- _workarea/admin/content/\_edit.html.haml_
- _workarea/admin/content/\_form.html.haml_

If your application is overriding either of these partials, you should apply this patch manually to your copies of the files.

## Adds Append Points

[#2533](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2533/overview), [#2534](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2534/overview)

Workarea 3.0.7 adds the following append point to the Admin.

_admin.user\_properties_ within _workarea/admin/users/edit.html.haml_

And adds the following append point to the Storefront.

_storefront.style\_guide\_components.property_ within _workarea/storefront/style\_guides/components/\_property.html.haml_

If your application is overriding either of the above views/partials, you may want to add these append points to your copies so that plugins can take advantage of these extension points.

## Stores Relative Paths for Product Images in Elasticsearch

[#2561](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2561/overview)

Prior to 3.0.7, Workarea stores absolute URLs for product images in Elasticsearch. Workarea 3.0.7 uses relative paths instead, which avoids the need to re-index when moving data between environments.

The PR changes the Core query `Workarea::ProductPrimaryImageUrl`. It modifies the implementation of `Workarea::ProductPrimaryImageUrl#url` and adds `Workarea::ProductPrimaryImageUrl#image` (extracted from `#url`) and `Workarea::ProductPrimaryImageUrl#path`.

The change also modifies the Core helper `Workarea::ApplicationHelper`. It edits the implementation of `Workarea::ApplicationHelper#product_image_url` and adds `Workarea::ApplicationHelper#product_image_path` (extracted from `#product_image_url`).

Furthermore, the change modifies the search model method `Workarea::Search::Storefront::Product#primary_image`.

In the Storefront, the PR changes the view model `Workarea::Storefront::SearchSuggestionViewModel`. It modifies the implementation of `Workarea::Storefront::SearchSuggestionViewModel#image`, adds `Workarea::Storefront::SearchSuggestionViewModel#asset_host`, and also makes the following methods public.

- `Workarea::Storefront::SearchSuggestionViewModel#source`
- `Workarea::Storefront::SearchSuggestionViewModel#name`
- `Workarea::Storefront::SearchSuggestionViewModel#type`
- `Workarea::Storefront::SearchSuggestionViewModel#image`
- `Workarea::Storefront::SearchSuggestionViewModel#suggestion_type`
- `Workarea::Storefront::SearchSuggestionViewModel#analytics`
- `Workarea::Storefront::SearchSuggestionViewModel#product`
- `Workarea::Storefront::SearchSuggestionViewModel#url`

Finally, the change adds a new view model test case, `Workarea::Storefront::SearchSuggestionViewModelTest`.

If your application is extending any of the methods affected by this change, you should review the PR and update your application code accordingly to benefit from this change.

## Changes Uniqueness Strategy for Workers

[7064a5eed91](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7064a5eed9145b813166bf9827af05f35ca37b12)

Workarea 3.0.7 modifies the following [workers](workers.html) to use the `until_executing` uniqueness strategy for [unique jobs](workers.html#unique-jobs). In earlier versions, these workers use the `until_and_while_executing` strategy, which can reportedly lead to race conditions that cause workers to not be enqueued.

- `Workarea::BulkIndexProducts`
- `Workarea::IndexAdminSearch`
- `Workarea::IndexCategorization`
- `Workarea::IndexCategory`
- `Workarea::IndexCategoryChanges`
- `Workarea::IndexFulfillmentChanges`
- `Workarea::IndexPage`
- `Workarea::IndexProduct`
- `Workarea::IndexProductChildren`
- `Workarea::IndexSearchCustomizations`
- `Workarea::IndexSkus`
- `Workarea::KeepProductIndexFresh`

If your application is extending the worker options on any of the above workers, you may want to apply this change to your application code to avoid workers not being enqueued.

## Improves Performance of Indexing Category Changes

[175f5260b8f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/175f5260b8ffef5926dd89c53fb30cf684bbd882)

Workarea 3.0.7 modifies the `Workarea::IndexCategoryChanges` worker to improve performance. The change adds an `ignore_if` option to the worker, and modifies the implementation of `Workarea::IndexCategoryChanges#perform`.

If your application is extending this worker, you may want to update your application code to ensure you are benefiting from this performance improvement.

## Adds Caching for Default Category of a Product

[e4b85c1fa4a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e4b85c1fa4a66bf69517e5a89a898b0b940d7ae0)

Workarea 3.0.7 modifies `Workarea::Categorization` query, adding a cache within `Workarea::Categorization#default_model` to resolve performance issues reported by systems integrators.

```
# workarea-core/app/queries/workarea/categorization.rb

module Workarea
  class Categorization
    # ...

    def default_model
      key = "#{@product.cache_key}/default_category"

      @default_model ||= Rails.cache.fetch(key, expires_in: 1.day) do
        to_models.sort_by(&:created_at).first
      end
    end

    # ...
  end
end
```

If your application is extending this method, ensure your implementation does not conflict with these changes.

## Fixes Tax Price Adjustment Amount

[#2553](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2553/overview)

`Workarea::Pricing::TaxApplier#assign_item_tax` is responsible for writing a price adjustment that adjusts tax to a shipping. Prior to 3.0.7, the amount of that adjustment is incorrect under certain conditions (order affected by multiple tax codes and a discount). Workarea 3.0.7 applies the following changes to fix the issue.

- Modifies implementation of Core model method `Workarea::Pricing::TaxApplier#assign_item_tax`
- Adds Core model method `Workarea::PriceAdjustmentSet#grouped_by_parent`
- Adds Core model test `Workarea::Pricing::TaxApplierTest#test_with_multiple_tax_codes_and_discount`

If your application is extending the tax applier, update your implementation accordingly to fix this issue.

## Adds Argument for Wait for XHR Timeout Threshold

[#2552](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2552/overview)

Workarea 3.0.7 modifies `Workarea::SystemTest#wait_for_xhr`, allowing the maximum wait time to be passed as an argument.

```
# workarea-testing/lib/workarea/system_test.rb
# ...

module Workarea
  class SystemTest < IntegrationTest
    # ...

    def wait_for_xhr(time=Capybara.default_max_wait_time)
      Timeout.timeout(time) do
        loop until finished_all_xhr_requests?
      end
    end

    # ...
  end
end
```

Use this argument to call the method with an arbitrary timeout threshold that differs from the configured default.


