---
title: Workarea 3.0.10
excerpt: #2687, #2694
---

# Workarea 3.0.10

## Fixes Test Runners on Rails 5.0.5

[#2687](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2687/overview), [#2694](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2694/overview)

Rails 5.0.5 includes [significant changes](https://github.com/rails/rails/pull/29572) to the Rails test runner, which break the [test runners](testing.html#listing-test-runners) used by Workarea applications. Workarea 3.0.10 makes the following changes to ensure continued functionality of the test runners after upgrading to Rails 5.0.5.

- Changes `Minitest.rake_run` to `Rails::TestUnit::Runner.rake_run` throughout _workarea-core/lib/tasks/tests.rake_
- Removes _workarea-core/lib/minitest/workarea\_plugin.rb_ and _workarea-core/lib/workarea/ext/rails/test\_requirer.rb_
- Adds `Workarea::DecorationReporter` at _testing/lib/workarea/testing/decoration\_reporter.rb_, which implements `format_rerun_snippet` on `Rails::TestUnitReporter`

## Fixes Storefront Cancelation Email to Correctly List Canceled Items

[#2689](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2689/overview)

Workarea 3.0.10 fixes the Storefront cancelation email to correctly list canceled items.

The change modifies `Workarea::Fulfillment#cancel_items` in Core.

The PR also modifies the following Storefront mailers.

- _workarea/storefront/fulfillment\_mailer/canceled.html.haml_
- _workarea/storefront/fulfillment\_mailer/canceled.text.erb_

Finally, the PR updates `test_canceled_order_updates_the_fulfillment_status_of_the_order` in `Workarea::Storefront::FulfillmentSystemTest`

## Blocks Malicious Credit Card Requests

[#2673](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2673/overview)

Workarea 3.0.10 modifies the [Rack::Attack](https://rubygems.org/gems/rack-attack/versions/5.0.1) ([docs](http://www.rubydoc.info/gems/rack-attack/5.0.1)) initializer, _workarea-core/config/initializers/13\_rack\_attack.rb_, creating a new blocklist intended to protect against malicious credit card requests. These requests, which place orders and save credit cards in order to test credit card lists, strain infrastructure and burden the retailer with credit card fees.


