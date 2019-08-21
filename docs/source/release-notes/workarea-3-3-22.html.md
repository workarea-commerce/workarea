---
title: Workarea 3.3.22
excerpt: Patch release notes for Workarea 3.3.22.
---

# Workarea 3.3.22

Patch release notes for Workarea 3.3.22.

## Restore `Sidekiq::Callbacks` Worker State after Error

If an error is raised in the block of a `Sidekiq::Callbacks` worker
configuration, the enabled/disabled (or async/inline) state would previously
not be restored. This resulted in background jobs randomly not running.
To fix this, Workarea now ensures that the state is restored at the end
of temporary configuration blocks passed to `Sidekiq::Callbacks`.

### Issues

- [ECOMMERCE-6753](https://jira.tools.weblinc.com/browse/ECOMMERCE-6753)

### Pull Requests

- [3906](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3906/overview)

## Fix Typo in CSS for Content Preview Visibility

Ensure `position: initial` is spelled correctly so the `else` condition
of the `content-preview-visibility-state()` mixin defined in this file
will work.

Discovered (and solved) by **Kristin Everham**. Thanks Kristin!

### Issues

- [ECOMMERCE-6746](https://jira.tools.weblinc.com/browse/ECOMMERCE-6746)

### Pull Requests

- [3900](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3900/overview)

## Fix Date Selector Dropping Below Workflow Bar

Center browsing control filter dropdowns with respect to their trigger.
This allows more flexibility for use outside of the traditional browsing
control UI. Also, Display Browsing Controls & Filters above the workflow
bar.

### Issues

- [ECOMMERCE-6723](https://jira.tools.weblinc.com/browse/ECOMMERCE-6723)

### Pull Requests

- [3886](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3886/overview)

## Always Fire Analytics Events in Development

When developing or testing an application, analytics events should
always fire so that admins can still test their code without any
confusing results.

### Issues

- [ECOMMERCE-6708](https://jira.tools.weblinc.com/browse/ECOMMERCE-6708)

### Pull Requests

- [3867](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3867/overview)

## Fix Sidekiq Concurrency Configuration

Prevent timeouts in background job workers by ensuring that the Sidekiq
connection pool is stocked with enough connections.

### Issues

- [ECOMMERCE-6715](https://jira.tools.weblinc.com/browse/ECOMMERCE-6715)

### Pull Requests

- [3872](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3872/overview)

## Disable Shipping Method Selection When Processing

Prevent shipping method from getting selected when Workarea is still
pricing the order. Additionally, set the `WORKAREA.shippingServices.requestTimeout`
to '1' in order to prevent any other parallel shipping estimate requests from
causing a locked order and showing strange errors to the user, including
flashes of error text and incorrect shipping price totals in the
summary. By disabling the radio input whenever a shipping service is
selected, and re-enabling it when the request is complete, the scenario
of obtaining an incorrect shipping price and thus being kicked back to
shipping to re-select is no longer possible to trigger. Ensure order locking
doesn't redirect the user to the `/cart` route, which is _not_ protected by
`#with_order_lock`, and can potentially cause a race condition in pricing.

### Issues

- [ECOMMERCE-6692](https://jira.tools.weblinc.com/browse/ECOMMERCE-6692)

### Pull Requests

- [3873](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3873/overview)
- [3894](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3894/overview)

## Fix Release Publishing After Removing Date to Publish

When a Release is scheduled to publish in the future, a
`Workarea::PublishRelease` is scheduled in the background, wherein it
will be picked up by Sidekiq at the time it's supposed to be released.
However, when removing the `:publish_at` date from the release in admin
(or anywhere else), this job was not getting removed from Sidekiq, and
thus would publish at the date it was formerly scheduled to release at.
Workarea now removes this extra job from the scheduler as well as its
undo job, so that the release will not accidentally affect data in the
future.

### Issues

- [ECOMMERCE-6755](https://jira.tools.weblinc.com/browse/ECOMMERCE-6755)

### Pull Requests

- [3911](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3911/overview)
