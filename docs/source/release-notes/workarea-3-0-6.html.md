---
title: Workarea 3.0.6
excerpt: #2523
---

# Workarea 3.0.6

## Fixes Same-Day Date Filtering in Admin

[#2523](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2523/overview)

Workarea 3.0.6 fixes search queries where the start and end dates are set to the same value by adding `Workarea::Search::DateFilter` and `Workarea::Search::DateFilterTest` and modifying the implementations of `Workarea::Search::AdminIndexSearch#filters` and `Workarea::Search::AdminOrders#filters` to use instances of the new `DateFilter` instead of `RangeFilter`.

The change also modifies the following integration test methods.

- `Workarea::Search::AdminOrdersTest#create_orders`
- `Workarea::Search::AdminOrdersTest#test_filter`
- `Workarea::Search::AdminOrdersTest#test_aggregations`
- `Workarea::Search::AdminOrdersTest#test_sort`
- `Workarea::Search::AdminOrdersTest#test_filter_by_date`

![date filter same day](images/date-filter-same-day.png)

If your application is extending either of the above `filters` methods or the associated test methods, update your application code accordingly.

## Fixes Parameters in Admin Dashboard Links

[#2528](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2528/overview)

Workarea 3.0.6 fixes the link to _Today's Signups_ on the Admin's _People_ dashboard and fixes the links to _Today's Orders_ and _Yesterday's Orders_ on the _Orders_ dashboard.

![People dashboard links](images/people-dashboard-links.png)

![Orders dashboard links](images/orders-dashboard-links.png)

The change modifies the _workarea/admin/dashboards/people.html.haml_ Admin view and the following helper methods.

- `Workarea::Admin::NavigationHelper#todays_signups_path`
- `Workarea::Admin::NavigationHelper#todays_orders_path`
- `Workarea::Admin::NavigationHelper#yesterdays_orders_path`

If your applications is extending any of the above methods or overriding the above view, review the pull requests and update your application code accordingly.

## Fix Empty Country & Region Fields in Storefront

[#2522](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2522/overview), [#2530](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2530/overview), [#2531](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2531/overview), [#2513](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2513/overview)

Workarea 3.0.6 fixes _country_ and _region_ fields within Storefront address forms. Prior to this fix, the fields could appear empty on page load or after choosing a saved address, despite the data being present in the model. The change also removes client-side validation on the _region_ field since some countries don't have regions.

The following sections summarize the changes to Core and Storefront.

### Core

The changes modify `Workarea::Address#region_name` and add `Workarea::AddressTest#test_region_name`.

Also added are `Workarea::Address#as_json` and `Workarea::AddressValidationTest#test_as_json`. The following instance methods are also moved from `Workarea::AddressTest` to `Workarea::AddressValidationTest` due to a module name being corrected.

- `set_config`
- `reset_config`
- `test_country_validation`
- `test_postal_code_validation`
- `test_region_validation`
- `test_field_length_validation`

The changes modify the implementation of the following helper methods.

- `Workarea::AddressesHelper#country_options`
- `Workarea::AddressesHelper#formatted_address`

### Storefront

Within the Storefront, the following JavaScript modules are modified.

- _workarea/storefront/modules/address\_region\_fields.js_
- _workarea/storefront/modules/checkout\_addresses\_forms.js_

The changes modify the _workarea/storefront/shared/\_address\_fields.html.haml_ view and the `Workarea::Storefront::LoggedInCheckoutSystemTest#test_preselecting_addresses_from_saved_addresses` helper method. The following helper methods are added.

- `Workarea::Storefront::GuestCheckoutSystemTest#save_country_config`
- `Workarea::Storefront::GuestCheckoutSystemTest#reset_country_config`
- `Workarea::Storefront::GuestCheckoutSystemTest#test_regionless_country`

If your application is extending any of the above methods or overriding the above JavaScript modules or views, you'll need to to update your application code to ensure these patches are applied correctly.

## Fixes Async Add to Cart

[#2527](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2527/overview)

Async add to cart in the Storefront can fail due to an XHR race condition causing the cookie with the current order id to be replaced after the item is added to cart. Workarea 3.0.6 makes the following changes within the Storefront to mitigate this and similar problems.

- Modify `Workarea::Storefront::HttpCaching#cache_page` to disable session on pages with HTTP caching.
- Modify _workarea/storefront/modules/product\_details\_sku\_selects.js_ to disable the add to cart button while a SKU change request is pending.

If you are overriding this JavaScript module or extending `cache_page`, you should update your application code to ensure this patch is applied correctly.

## Fixes Mobile Navigation Behavior

[#2524](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2524/overview)

Prior to 3.0.6, clicking a menu within the Storefront's mobile navigation could reload the page instead of asynchronously loading the menu's content. Workarea 3.0.6 fixes this problem by modifying the _workarea/storefront/menus/index.html.haml_ Storefront view, binding the behavior to the presence of the menu's content rather than the taxon's children (which is irrelevant in this context). The change also modifies the `Workarea::Storefront::NavigationSystemTest#test_mobile_navigation_menus` system test method.

If your application is overriding this view, you should apply this change in your copy of the file to apply the fix.

## Fix Workarea Configuration within System Tests

[bff1b44e3f6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/bff1b44e3f67e665ab6cfbcfe9955fbf4783c99a)

Workarea 3.0.6 changes `Workarea.config` and `Workarea.with_config` to use instance variables rather than thread variables since Capybara runs its server in a separate thread.

If your application is extending these methods, update your application code accordingly to prevent unexpected behavior in the Test environment.

## Fixes Fulfillment Quantities in Admin

[#2508](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2508/overview)

Workarea 3.0.6 fixes incorrect fulfillment quantities in the Admin when multiple fulfillment events affect a fulfillment item (such as shipping an order, then canceling it).

The change renames `Workarea::Fulfillment::Package#items` to `Workarea::Fulfillment::Package#events_by_item` and modifies implementation details within the following methods.

- `Workarea::Admin::FulfillmentViewModel#pending_items`
- `Workarea::Admin::FulfillmentViewModel#cancellations`
- `Workarea::Admin::PackageViewModel#items`
- `Workarea::Storefront::PackageViewModel#items`
- `Workarea::Storefront::OrderViewModel#canceled_items`

If your application is decorating any of these APIs, review the pull request and update your application code accordingly.

## Fixes Feature Test JavaScript

[#2512](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2512/overview), [#2515](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2515/overview)

In the _test_ environment, Workarea loads _workarea/core/feature\_spec\_helper.js_ in the Storefront to explicitly fail various browser feature tests (such as animations and touch support) that are undesirable or incorrectly reported in the test environment (PhantomJS). Prior to 3.0.6, this file also removes from the `html` element several class values that represent successful browser feature tests. However, a race condition may occur, causing the class values to be added after the code to remove them has run. The inclusion of those classes can cause intermittent test failures.

Workarea 3.0.6 re-orders the contents of the Storefront's _workarea/storefront/head.js.erb_ manifest to avoid this race condition. The change also removes code that is no longer needed after changing the load order.

If your application is overriding this manifest, you must update your copy of the file to avoid intermittent test failures.

## Fixes Storefront Error Dialog

[#2518](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2518/overview)

Workarea 3.0.6 fixes the Storefront error dialog by correcting the value of `WORKAREA.config.dialog.errorTemplate.path`, which changed in a previous release. The change modifies the Storefront JavaScript config file, _workarea/storefront/config.js.erb_.

If your application is overriding this file, you'll need to apply this change in your copy. However, overriding this file is not recommended. If you are doing so, consider creating a JavaScript config file for your application, which you can use to modify or replace configuration values as needed.

## Allows Plugins to Extend Test Setup & Configuration

[1e2fea5a65b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1e2fea5a65b1270fb485de185ee5be93f4de9e1d)

Workarea Testing 3.0.6 allows each Workarea plugin to provide additional test support files within its _test/support/_ directory. These files may be used to add or extend the test setup and configuration as needed for the plugin.

Applications will `require` these files from each installed plugin when running tests.

```
# workarea-testing/lib/workarea/test_help.rb

# ...

Workarea::Plugin.installed.each do |plugin|
  Dir[plugin.root.join('test', 'support', '**', '*.rb')].each do |support_file|
    require support_file
  end
end
```

