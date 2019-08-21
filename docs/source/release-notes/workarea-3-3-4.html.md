---
title: Workarea 3.3.4
excerpt: Patch release notes for Workarea 3.3.4.
---

# Workarea 3.3.4

Patch release notes for Workarea 3.3.4.

## Bump Puma To Latest Minor Version

This helps fix local networking issues with Docker setups, but there are
more features that might tickle your fancy.

[Read all about it!](https://github.com/puma/puma/releases/tag/v3.11.0)

### Issues

- [ECOMMERCE-6169](https://jira.tools.weblinc.com/browse/ECOMMERCE-6169)

### Commits

- [d9b9a1f9ae95f930790f566f715d3f8d2597fe4e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d9b9a1f9ae95f930790f566f715d3f8d2597fe4e)


## Depend on workarea-ci

Workarea now depends on a new library, **workarea-ci**, designed to support
CI-based builds of the Workarea application. Within it, you'll find
prescribed scripts that run each component of the Workarea core
platform, as well as facilities for running your own apps in this
manner. Separated by script file, each component's tests are now executable
in parallel on CI, in a repeatable and battle-tested way.

### Issues

- [ECOMMERCE-6178](https://jira.tools.weblinc.com/browse/ECOMMERCE-6178)

### Pull Requests

- [3480](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3480/overview)

### Commits

- [609b12a831786af3fc896aaf66a47c801813fd13](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/609b12a831786af3fc896aaf66a47c801813fd13)


## Allow Mongoid To Specify Mongo Driver Dependency

This was originally committed to [fix an issue with the Ruby
driver](https://jira.mongodb.org/browse/RUBY-12856168), which was since
resolved upstream. Removing this dependency specification allows
Mongoid to dictate its Mongo driver version, and benefits the platform
by ensuring that Workarea apps are always as up-to-date as it can be
when communicating with the database.

### Issues

- [ECOMMERCE-6168](https://jira.tools.weblinc.com/browse/ECOMMERCE-6168)

### Pull Requests

- [3477](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3477/overview)

### Commits

- [958e9f8a483c6642ec0aebb42f63f2ef59f892ec](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/958e9f8a483c6642ec0aebb42f63f2ef59f892ec)


## Allow Decimal Values in Range Field Number Input

Range number fields in content editor forms need the `step` attribute to
be set in order to allow their values to be set to a floating-point or
non-Integer. Ensures that input for this field will not exceed what the
range specifies, and allows decimal values as the input.

### Issues

- [ECOMMERCE-6158](https://jira.tools.weblinc.com/browse/ECOMMERCE-6158)

### Pull Requests

- [3467](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3467/overview)

### Commits

- [1ed5f51b1d00c523734e5f4e3c35427812bc7aa8](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1ed5f51b1d00c523734e5f4e3c35427812bc7aa8)


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


## Remove Transactional Email Content Nesting

Due to content blocks being able to define their own HTML markup,
wrapping their containing elements in a different containing element
caused visual problems in some email templates. This change pulls the content block
out of the nested HTML tag and lets it define its own markup.

### Issues

- [ECOMMERCE-6122](https://jira.tools.weblinc.com/browse/ECOMMERCE-6122)

### Pull Requests

- [3484](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3484/overview)

### Commits

- [3605b9ff815b1f92ad5fddf9d0083dfde5b432a4](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/3605b9ff815b1f92ad5fddf9d0083dfde5b432a4)


## Fix Session Access in Cache Varies Configuration

Upon release of this feature, accessing the `session` hash within the
`Cache::Varies.on { ... }` configuration caused an error due to a
missing `rack.session.options` value. Since the feature depends on our
use of `ActionDispatch::Session::CookieStore`, Workarea now throws an
error when a different store as in use, such as a `NullStore` in
testing.

### Issues

- [ECOMMERCE-6181](https://jira.tools.weblinc.com/browse/ECOMMERCE-6181)

### Pull Requests

- [3487](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3487)

### Commits

- [31f7d47325d24fb652b255ef86b27a73242b7973](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/31f7d47325d24fb652b255ef86b27a73242b7973)

## Fix Spelling Error In Scroll To Buttons Configuration

Although Workarea probably has the "offest" offsets of any eCommerce product,
the incorrect spelling of the `WORKAREA.config.scrollToButtons.topOffset`
configuration caused problems in the `WORKAREA.scrollToButtons` module. The
spelling of this configuration setting has been fixed, so it can be useful in
projects going forward.

Solved by **Lucas Boyd**.

### Issues

- [ECOMMERCE-6185](https://jira.tools.weblinc.com/browse/ECOMMERCE-6185)

### Pull Requests

- [3486](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3486/overview)

### Commits

- [7d00f407b13b4582089bde2f51e65ac5211f0fa1](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7d00f407b13b4582089bde2f51e65ac5211f0fa1)


## Explicitly Require Dragonfly's S3 Data Store

Since Workarea depends on Dragonfly's S3 Data Store, ensure that it's
required in Ruby before applying S3 configuration upon app
initialization.

### Issues

- [ECOMMERCE-6166](https://jira.tools.weblinc.com/browse/ECOMMERCE-6166)

### Commits

- [2bbdbbf3aad5ea7a73c231ca3c180d38b0a77a9a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2bbdbbf3aad5ea7a73c231ca3c180d38b0a77a9a)


## Fix Regular Expression In Pattern For Details/Filters

Product filters were not editable in the workflow because the regex we
added in did not work properly. This fixes the regex by removing the
modifier and slashes for the "type" field.

### Issues

- [ECOMMERCE-6161](https://jira.tools.weblinc.com/browse/ECOMMERCE-6161)

### Pull Requests

- [3470](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3470/overview)

### Commits

- [e7ae3c85b15a0424af8f8a1acfb65f504d050b88](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e7ae3c85b15a0424af8f8a1acfb65f504d050b88)

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

## Add Docker Generator

Generates `Dockerfile`, `docker-compose.yml`, and other associated
configuration files for running Workarea applications (and dependent
services) in local Docker containers. The generator also whitelists the
`web_console` ports so developers can get a debugger console at any
breakpoint in their application.

### Issues

- [ECOMMERCE-6100](https://jira.tools.weblinc.com/browse/ECOMMERCE-6100)
- [ECOMMERCE-6177](https://jira.tools.weblinc.com/browse/ECOMMERCE-6177)

### Pull Requests

- [3478](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3478/overview)
- [3444](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3444/overview)
- [3479](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3479/overview)

### Commits

- [492fa6d9c5b7c92e69320011ef2b0f0ad913a7b7](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/492fa6d9c5b7c92e69320011ef2b0f0ad913a7b7)
- [d182d05ea36af235892c0aa056e884abe3a6112a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d182d05ea36af235892c0aa056e884abe3a6112a)
- [62bc5147268df68963b77532b528328e0da5e91c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/62bc5147268df68963b77532b528328e0da5e91c)
- [b7c82b2bc3631cab966566dac5285b173b451ce4](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b7c82b2bc3631cab966566dac5285b173b451ce4)


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


