---
title: Workarea 3.0.35
excerpt:  In certain cases, like with the Workarea::MultiSite plugin, impersonating users can cause unexpected behavior because the impersonation status check can run before multisite changes the database. This change moves that status check (called :check_imp
---

# Workarea 3.0.35

## Fix Unexpected Behavior When Impersonating Users

In certain cases, like with the `Workarea::MultiSite` plugin, impersonating users can cause unexpected behavior because the impersonation status check can run before multisite changes the database. This change moves that status check (called `:check_impersonation`) above any other manipulation of the session by way of the `prepend_before_action` method, to prevent issues like this from happening in the future.

### Issues

- [ECOMMERCE-6078](https://jira.tools.weblinc.com/browse/ECOMMERCE-6078)

### Pull Requests

- [3409](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3409)

### Commits

- [be33b52b124cf3276d6bdfe13bfd9f13ea9ceb43](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/be33b52b124cf3276d6bdfe13bfd9f13ea9ceb43)

## Make Orderdataintegrationtest Less Great Again

This test was originally named `Storefront::OrderDataIntegreationTest`, and thus caused issues when decorated due to the file name and class name not matching up. We've renamed the class to`Storefront::OrderDataIntegrationTest`.

While the test is ostensibly much less great due to this change, it does allow implementers to decorate its methods, thus improving its usefulness in our platform.

Discovered by "The Reformed" **Francisco Galarza**

### Issues

- [ECOMMERCE-5551](https://jira.tools.weblinc.com/browse/ECOMMERCE-5551)

### Pull Requests

- [3416](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3416)

### Commits

- [6a1d83e56b11b5f9e5a0012df7be0a0594493416](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6a1d83e56b11b5f9e5a0012df7be0a0594493416)

## Prevent Duplicate ID Errors When Editing Featured Products In Category And Product/variant Details

Duplicate ID errors were occurring in certain cases on the featured products forms, catalog product workflow, and variant forms. Since Rails will (by default) set IDs on each DOM element we are creating with its tag helpers, we're now passing `id: nil` so IDs are not generated at all.

Discovered by **Kristin Henson** in featured category products, with an important assist by **Kristen Ward** , who reported the issue in product/variant details.

### Issues

- [ECOMMERCE-5864](https://jira.tools.weblinc.com/browse/ECOMMERCE-5864)

### Pull Requests

- [3390](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3390)

### Commits

- [971b9a157436d41a0cf0af8c9821ed3cd55da16f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/971b9a157436d41a0cf0af8c9821ed3cd55da16f)

## Use Fully-qualified Url For Homepage Open Graph Image Tag

Content pages were still using the `image_path` syntax to render URLs tothe logo image. This wasn't working on social media networks, whereinthe URL lookup would result in an error. Changing this to `image_url`,which incorporates the host, allows pages to be shared on social media.

Discovered by **Kristin Henson**.

### Issues

- [ECOMMERCE-6106](https://jira.tools.weblinc.com/browse/ECOMMERCE-6106)

### Pull Requests

- [3431](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3431/overview)

### Commits

- [89e546c87913a671863ff3655db4156cec9374b1](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/89e546c87913a671863ff3655db4156cec9374b1)

## Prevent Error When Svg File Cannot Be Found

In the base implementation of `InlineSvg`, it would seem that locally, we assume that an SVG file is present in Sprockets, and if it isn't an error occurs. This `NoMethodError` is difficult to reason about as a developer, so we're rescuing and treating the response as if we're missing the SVG, leveraging the existing system in place for handling that error.

Discovered by **Matt Dunphy**.

### Issues

- [ECOMMERCE-6046](https://jira.tools.weblinc.com/browse/ECOMMERCE-6046)

### Pull Requests

- [3407](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3407)

### Commits

- [e551154f2affcec9995ef3e7b96902b93aede9d4](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e551154f2affcec9995ef3e7b96902b93aede9d4)

## Submit New Content Preset Inline Form Asynchronously

The "add content preset" form shows up in a tooltip, and when creating a new content preset within a workflow, the form submission refreshes the page and knocks the user out of the workflow. We've remedied this by making the form submission asynchronous, so the page won't refresh and the workflow won't get broken. Results of the operation are showed in either an error or success flash message.

### Issues

- [ECOMMERCE-5820](https://jira.tools.weblinc.com/browse/ECOMMERCE-5820)

### Pull Requests

- [3328](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3328/overview)
- [3355](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3355/overview)

### Commits

- [e0a1b4414b4f10d14b14d1cf23622cabb8a86822](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e0a1b4414b4f10d14b14d1cf23622cabb8a86822)
- [2c05d3cb34b7fbd5ab11bf8c54086ebc9f6b802f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2c05d3cb34b7fbd5ab11bf8c54086ebc9f6b802f)

## Lock Down Rufus-scheduler

The `Rufus::Scheduler` library that `Sidekiq::Cron` uses for parsing schedule information refactored some of their codebase, and as a result caused a breaking change in the `Sidekiq::Cron` library. The fix for this has not been released yet, so we've made sure to lock down the rufus-scheduler gem to a slightly lower version in order to avoid this issue.

### Issues

- [ECOMMERCE-6060](https://jira.tools.weblinc.com/browse/ECOMMERCE-6060)

### Pull Requests

- [3399](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3399)

### Commits

- [1d54ae67488fea176c25732c4dd33da968732dcf](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1d54ae67488fea176c25732c4dd33da968732dcf)

## Remove Currency From Structured Pricing Data

In the `workarea/storefront/products/_price` partial, we were returning the full currency with the price in the `price` data point. We're now returning the numerical value of the price without its currency, as it's already denoted above in `priceCurrency`.

Discovered by **Kristin Henson**

### Issues

- [ECOMMERCE-6064](https://jira.tools.weblinc.com/browse/ECOMMERCE-6064)

### Pull Requests

- [3418](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3418/overview)

### Commits

- [1a929740a5d21611076e4c58be588c3cc11f5046](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1a929740a5d21611076e4c58be588c3cc11f5046)

## Fix Wcag Issues After Axe Accessibility Audit

After performing the WCAG 2.0 accessibility audit with [aXe](https://www.deque.com/axe/), we fixed a large amount of accessibility issues in the admin and storefront, such as missing `aria-` attributes and `role` definitions for the vast array of elements on each page. This change affects both admin and storefront, and should prevent issues on future accessibility scans as a whole.

### Issues

- [ECOMMERCE-6035](https://jira.tools.weblinc.com/browse/ECOMMERCE-6035)

### Pull Requests

- [3432](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3432/overview)
- [3437](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3437/overview)
- [3436](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3437/overview)
- [3435](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3435/overview)

### Commits

- [d0e0dbcc5f4a283ea2312b258dd229f64ea9804f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d0e0dbcc5f4a283ea2312b258dd229f64ea9804f)
- [c36d099f9a336b5820dbee64547cb356db9dacb1](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c36d099f9a336b5820dbee64547cb356db9dacb1)
- [10b2cccec55a9203b11c9efa6e493ede3c5b78eb](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/10b2cccec55a9203b11c9efa6e493ede3c5b78eb)
- [c9d144606e5717b69e8b8ab9642e3f27e4acd422](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c9d144606e5717b69e8b8ab9642e3f27e4acd422)

## Prevent Duplicate IDs When Editing Content Blocks

By default, the Rails form helper tags will generate an ID based on the `name` attribute of the element and the name of the `` tag it's surrounded by. Because fieldsets within the same form sometimes share names, we used the `dom_id()` helper method to generate mostly-unique DOM IDs for each element. As we gradually shifted to a more asynchronous and feature-rich content editor, it was observed that duplicate IDs were appearing on the page for different fieldsets, or sometimes the same fieldset rendered multiple times in a content block. To prevent this, we're now setting `id: nil` on all tags that previously had a `dom_id` associated with it. This will ensure that Rails won't generate an ID onthe DOM element, which is not necessary given the way we handle styling and behavior for elements on the page.

### Issues

- [ECOMMERCE-5873](https://jira.tools.weblinc.com/browse/ECOMMERCE-5873)

### Pull Requests

- [3389](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3389)

### Commits

- [930842818c548bcd4ef4d51ab99c390f98c579f8](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/930842818c548bcd4ef4d51ab99c390f98c579f8)

## Fix Broken Tests When Activemerchant Gateway Connected to Real Url

[In a recent update to ActiveMerchant](https://github.com/activemerchant/active_merchant/commit/b20ad8a287567868ffce067e453f94c40935c317), a refinement on the `Net::HTTP` library was made to log additional SSL connection details, in accordance with a future PCI compliance restriction. This had the effect of breaking some tests in a client build, which had some integration tests set up to work with `VCR`. VCR's usage of `Webmock`, and the way Webmock ensures `Net::HTTP` doesn't actually make HTTP requests, caused a `NoMethodError` in tests. This has been [resolved upstream](https://github.com/activemerchant/active_merchant/pull/2874), so once a new version of ActiveMerchant is released, we'll remove this change from the platform and depend on the higher version.

Discovered by **Joe Giambrone**.

### Issues

- [ECOMMERCE-6099](https://jira.tools.weblinc.com/browse/ECOMMERCE-6099)

### Pull Requests

- [3430](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3430/overview)

### Commits

- [b202166c39576e1abf0a745938dc86bffd506dc8](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b202166c39576e1abf0a745938dc86bffd506dc8)

