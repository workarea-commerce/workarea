---
title: Workarea 3.3.1
excerpt:  When one of the choices within the release reminder tooltip gets selected, close the entire tooltip. This is a regression due to a change in behavior within Tooltipster, which we've addressed in previous patches. 
---

# Workarea 3.3.1

## Close Tooltip Once Choice Made in Release Reminder Form

When one of the choices within the release reminder tooltip gets selected, close the entire tooltip. This is a regression due to a change in behavior within Tooltipster, which we've addressed in previous patches.

### Issues

- [ECOMMERCE-6058](https://jira.tools.weblinc.com/browse/ECOMMERCE-6058)

### Pull Requests

- [3401](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3401/overview)

### Commits

- [b0cc813ec90f22ce1952faa4accd3d178c82c842](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b0cc813ec90f22ce1952faa4accd3d178c82c842)

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

## Fix Releasesintegrationtests When Time Zone Is Set

With the new release calendar export option added in v3.3, the`Admin::ReleasesIntegrationTest` will fail when `config.time_zone` is configured, resulting in the calendar no longer generating for UTC. To remedy this, we're forcing UTC time zone on all these tests and resetting back to the original time zone after each test runs, ensuring that we are always testing against the same time zone, except in the one unit test that we assert the calendar can operate in multiple timezones.

### Issues

- [ECOMMERCE-6085](https://jira.tools.weblinc.com/browse/ECOMMERCE-6085)

### Pull Requests

### Commits

- [4b612d0d7ab161fc1105148fef9a62fec8fe7122](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4b612d0d7ab161fc1105148fef9a62fec8fe7122)
- [f2bc5bdbe3cd13e33a1e0ec2ff00306ad33c075c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f2bc5bdbe3cd13e33a1e0ec2ff00306ad33c075c)

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

## Use Absolute Paths For Email Settings

By using relative paths in email settings, we inadvertently broke `assets:precompile` runs in production because the email templates don't have the same SCSS scope as the rest of the application. We're going back to using absolute paths when `@import`-ing SCSS files to ensure that variables always get loaded in the right place.

### Issues

- [ECOMMERCE-6084](https://jira.tools.weblinc.com/browse/ECOMMERCE-6084)

### Pull Requests

- [3424](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3424/overview)

### Commits

- [42aca09bab325bd7d57293358a5059bb28320c0f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/42aca09bab325bd7d57293358a5059bb28320c0f)

## Lock Down Rufus-scheduler

The `Rufus::Scheduler` library that `Sidekiq::Cron` uses for parsing schedule information refactored some of their codebase, and as a result caused a breaking change in the `Sidekiq::Cron` library. The fix for this has not been released yet, so we've made sure to lock down the rufus-scheduler gem to a slightly lower version in order to avoid this issue.

### Issues

- [ECOMMERCE-6060](https://jira.tools.weblinc.com/browse/ECOMMERCE-6060)

### Pull Requests

- [3399](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3399)

### Commits

- [1d54ae67488fea176c25732c4dd33da968732dcf](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1d54ae67488fea176c25732c4dd33da968732dcf)

## Configurable Amount of Default Filter Values

Instead of hard-coding the facet filter size to `10`, make this value a configuration setting. Implementers can now set `Workarea.config.default_search_facet_result_sizes` to configure this value.

Solved by **Kristin Henson**.

### Issues

- [ECOMMERCE-6083](https://jira.tools.weblinc.com/browse/ECOMMERCE-6083)

### Pull Requests

- [3422](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3422/overview)

### Commits

- [33542e7267771703c3afcb4d48765e826ab76a46](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/33542e7267771703c3afcb4d48765e826ab76a46)

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

## Include Changelog in Gem Distribution

The `CHANGELOG.md` was previously not included in the `.gem` distribution of Workarea. Now it is, and you can view the file on your local installation:

```
less $(bundle show workarea)/CHANGELOG.md
```

Enjoy!

### Issues

- [ECOMMERCE-6110](https://jira.tools.weblinc.com/browse/ECOMMERCE-6110)

### Pull Requests

- [3439](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3439)

### Commits

- [b693170c5730637524eccb842031ab027e3c5e2c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b693170c5730637524eccb842031ab027e3c5e2c)

## Fix Pattern Validation For New Filter/detail Names

We don't allow the usage of the word "type" in a filter/detail name, and validate this on both the client-side and the server-side. When we removed the `jQuery.validate` plugin in order to fully rely on browser native input validation, we noticed that some of the regular expressions used for validation were not giving us the expected result. These regexes have been fixed and you can now get past adding details in the product edit, "create product" workflow, and bulk action sequential product editor.

### Issues

- [ECOMMERCE-6087](https://jira.tools.weblinc.com/browse/ECOMMERCE-6087)

### Pull Requests

- [3427](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3427/overview)

### Commits

- [1f60cd40562e5d2ed5e0637553e81117a3d0b8a3](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1f60cd40562e5d2ed5e0637553e81117a3d0b8a3)

## Prevent Duplicate IDs When Editing Content Blocks

By default, the Rails form helper tags will generate an ID based on the `name` attribute of the element and the name of the `` tag it's surrounded by. Because fieldsets within the same form sometimes share names, we used the `dom_id()` helper method to generate mostly-unique DOM IDs for each element. As we gradually shifted to a more asynchronous and feature-rich content editor, it was observed that duplicate IDs were appearing on the page for different fieldsets, or sometimes the same fieldset rendered multiple times in a content block. To prevent this, we're now setting `id: nil` on all tags that previously had a `dom_id` associated with it. This will ensure that Rails won't generate an ID onthe DOM element, which is not necessary given the way we handle styling and behavior for elements on the page.

### Issues

- [ECOMMERCE-5873](https://jira.tools.weblinc.com/browse/ECOMMERCE-5873)

### Pull Requests

- [3389](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3389)

### Commits

- [930842818c548bcd4ef4d51ab99c390f98c579f8](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/930842818c548bcd4ef4d51ab99c390f98c579f8)

## Prevent Order Locking When Updating Shipping Option

When the type of shipping service is changed and the form is submitted too quickly, an error can occur related to order locking, since the requests are coming in simultaneously. Implement a request queue using`_.debounce()` similarly to how we prevent this issue in **workarea-split\_shipping** , and disable the form for submission untilall requests finish.

### Issues

- [ECOMMERCE-6086](https://jira.tools.weblinc.com/browse/ECOMMERCE-6086)

### Pull Requests

- [3434](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3434)

### Commits

- [a41e9952aa33367d7be1375a8b7a82d96e62d184](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a41e9952aa33367d7be1375a8b7a82d96e62d184)

## Fix Broken Tests When Activemerchant Gateway Connected to Real Url

[In a recent update to ActiveMerchant](https://github.com/activemerchant/active_merchant/commit/b20ad8a287567868ffce067e453f94c40935c317), a refinement on the `Net::HTTP` library was made to log additional SSL connection details, in accordance with a future PCI compliance restriction. This had the effect of breaking some tests in a client build, which had some integration tests set up to work with `VCR`. VCR's usage of `Webmock`, and the way Webmock ensures `Net::HTTP` doesn't actually make HTTP requests, caused a `NoMethodError` in tests. This has been [resolved upstream](https://github.com/activemerchant/active_merchant/pull/2874), so once a new version of ActiveMerchant is released, we'll remove this change from the platform and depend on the higher version.

Discovered by **Joe Giambrone**.

### Issues

- [ECOMMERCE-6099](https://jira.tools.weblinc.com/browse/ECOMMERCE-6099)

### Pull Requests

- [3430](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3430/overview)

### Commits

- [b202166c39576e1abf0a745938dc86bffd506dc8](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b202166c39576e1abf0a745938dc86bffd506dc8)

