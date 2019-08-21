---
title: Workarea 3.0.37
excerpt: Patch release notes for Workarea 3.0.37.
---

# Workarea 3.0.37

Patch release notes for Workarea 3.0.37.

## Bump Puma To Latest Minor Version

This helps fix local networking issues with Docker setups, but there are
more features that might tickle your fancy.

[Read all about it!](https://github.com/puma/puma/releases/tag/v3.11.0)

### Issues

- [ECOMMERCE-6169](https://jira.tools.weblinc.com/browse/ECOMMERCE-6169)

### Commits

- [d9b9a1f9ae95f930790f566f715d3f8d2597fe4e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d9b9a1f9ae95f930790f566f715d3f8d2597fe4e)


## Specify Product Image Path Options Explicitly

Rather than allow Rails to infer them, specify `product_image_path`
options explicitly in its implementation, specifically the call to
`mounted_core.dynamic_product_image_path`. This helper can raise errors
at random times due to a difference in the attributes based on whether
Rails can or cannot infer their values, so it's less error-prone to
specify these parameters explicitly in the helper definition.

Discovered by **Greg Harnly**.

### Issues

- [ECOMMERCE-6143](https://jira.tools.weblinc.com/browse/ECOMMERCE-6143)

### Pull Requests

- [3488](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3488)

### Commits

- [df51d6ad1429575ccc88c1bcea5840822a4c8719](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/df51d6ad1429575ccc88c1bcea5840822a4c8719)


## Keep Payment Profile Email Address and Order Email Address Consistent

Payment profile email addresses should always be the same value as the
order email during the checkout process. However, in guest checkout it's
possible to bring these values out-of-sync by changing your email when a
payment profile has already been created for the order. This change
ensures that Workarea finds payment profiles by reference number _and_
email, and if not, creates a new record. This ensures that a new
payment profile record is created for each change to the email on an
order, and both fixes the issue for guests as well as prevents
against profile takeover of registered users (or existing users in the
system).

### Issues

- [ECOMMERCE-6167](https://jira.tools.weblinc.com/browse/ECOMMERCE-6167)

### Pull Requests

- [3490](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3490)

### Commits

- [59d81c24c1316acf9036dfaa28d3dbd362ce8db4](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/59d81c24c1316acf9036dfaa28d3dbd362ce8db4)
- [804bd9f7ede6fac8de2875e52cdcf94106b1ea75](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/804bd9f7ede6fac8de2875e52cdcf94106b1ea75)
- [2b0d8d702028d8b8efa731c7381c4f034e4a1393](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2b0d8d702028d8b8efa731c7381c4f034e4a1393)
- [2635595a5eacef1f55001cb481f8fb59a205add9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2635595a5eacef1f55001cb481f8fb59a205add9)


## Protect "Contact Us", Email Signup, and Forgot Password Forms from Denial-of-Service Attacks

Forms on the `/contact`, `/email_signup`, and `/forgot_password` pages
were open to Denial of Service attacks since they had no way of
throttling requests sent to those pages. Workarea now mitigates the
impact spammers might have on the resources of your application by
adding a `Rack::Attack` rule for POST requests to the above routes,
based on IP and/or email address. This also prevents Workarea from
needing to depend on CAPTCHA even further to prevent automated clients
from using the form.

### Issues

- [ECOMMERCE-6180](https://jira.tools.weblinc.com/browse/ECOMMERCE-6180)

### Pull Requests

- [3481](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3481)

### Commits

- [c03dc50b1bffe2498e9c5ac8da195c2f02e240ca](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c03dc50b1bffe2498e9c5ac8da195c2f02e240ca)


## Fix Indicator of Selected Category in Secondary Navigation

Fragment cache keys for a menu of taxons did not originally include the
ID of the selected taxon in the key, resulting in the page appearing
like the link was never selected. Workarea now avoids this problem by including
the selected taxon's ID in the fragment cache key for the menu.

### Issues

- [ECOMMERCE-6141](https://jira.tools.weblinc.com/browse/ECOMMERCE-6141)

### Pull Requests

- [3457](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3457/overview)

### Commits

- [2fb8ceb88604fe7c9a3f780d292f1b75d558834f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2fb8ceb88604fe7c9a3f780d292f1b75d558834f)

## Change Regions In Address Region Select Field, Regardless Of Dom Structure Changes

Update the `resetSelectUI()` function in `WORKAREA.addressRegionFields`
to query for the region `<select>` field in order to change its
contents. Previously, the order in which the order that DOM elements
were laid out on the page mattered, and a bug was discovered when the
two elements reversed position on the page layout. Now, the `$regionField`
from within the local `.address-fields` element is selected, improving
reliability and robustness in the JS code.

### Issues

- [ECOMMERCE-6189](https://jira.tools.weblinc.com/browse/ECOMMERCE-6189)

### Pull Requests

- [3492](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3492/overview)

### Commits

- [e76f2d15cd3784d49420ed8d582b19c229cba6e2](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e76f2d15cd3784d49420ed8d582b19c229cba6e2)


