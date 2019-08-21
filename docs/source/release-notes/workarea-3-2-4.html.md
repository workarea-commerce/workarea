---
title: Workarea 3.2.4
excerpt:  Seeding admin users doesn't always produce a valid password that works with our new secure requirements. Append a mixture of upper and lowercase characters to the end of each password that will always pass validation. 
---

# Workarea 3.2.4

## Add password requirements to newly generated accounts

Seeding admin users doesn't always produce a valid password that works with our new secure requirements. Append a mixture of upper and lowercase characters to the end of each password that will always pass validation.

### Issues

- [ECOMMERCE-5758](https://jira.tools.weblinc.com/browse/ECOMMERCE-5758)

### Pull Requests

- [3177](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3177)

- [311cc0b6baccf03f4049a0554582d26d1abf6ef1](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/311cc0b6baccf03f4049a0554582d26d1abf6ef1)

## Fix inconsistent default regular user permissions

We were using Mongoid's `:default` option on user permission fields to denote their default values. On the front-end, admins were complaining that users had "Releases" access on the admin, even though they don't have admin access. This prevents that from happening by setting those permissions which defaulted to `true` when the user becomes an admin, rather than when creating a new user account.

### Issues

- [ECOMMERCE-5591](https://jira.tools.weblinc.com/browse/ECOMMERCE-5591)

### Pull Requests

- [3167](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3167)

- [3c4b47f848da65598ba65830bec5e4140e94e26f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/3c4b47f848da65598ba65830bec5e4140e94e26f)

## Switch product image when variant changes in generic template

When selecting different options on the generic template, the product detail page changes asynchronously to reflect the new product details, but images not related to the variant are still visible. We're now passing all variant details as query paramters in the `GET` request, which has the effect of filtering images by the given option.

### Issues

- [ECOMMERCE-5226](https://jira.tools.weblinc.com/browse/ECOMMERCE-5226)

### Pull Requests

- [3052](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3052)
- [3131](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3131)

- [b7537102b343d938baaa86443c4d7e25c5fa6199](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b7537102b343d938baaa86443c4d7e25c5fa6199)
- [e917dc000f99b2a4c967d816feb904402575a83f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e917dc000f99b2a4c967d816feb904402575a83f)

## Translate the address fields partial

The address fields partial was not translated out-of-box, we're now adding the translations from address fields in the storefront into the admin fields partial

### Issues

- [ECOMMERCE-5781](https://jira.tools.weblinc.com/browse/ECOMMERCE-5781)

### Pull Requests

- [3175](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3175)

- [998b9d32b1a16d34e1b9475bb9612d05bc7a8c0c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/998b9d32b1a16d34e1b9475bb9612d05bc7a8c0c)

## Fix potential cookie overflow error in admin

When viewing admin pages with a lot of text on them, clicking the "Help" button could potentially have caused a cookie overflow error if the admin's session expired at the same time as they clicked the button. This is because the amount of content in the `like_text` param in the URL is too large for the `:return_to` session value (stored in a client-side cookie). We introduced a new configuration value named `return_to_url_max_length` that prescribes the amount of characters in a `:return_to` URL. This prevents help URLs from being too long for storage in a client-side cookie.

### Issues

- [ECOMMERCE-5387](https://jira.tools.weblinc.com/browse/ECOMMERCE-5387)

### Pull Requests

- [3170](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3170)

- [2c42f23199cce8848dcc4735fb95e743899e05b4](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2c42f23199cce8848dcc4735fb95e743899e05b4)

## Include plugin SVGs on style guide

We weren't including new SVG icons introduced by plugins in style guides. This made finding all the icons at your disposal in a given implementation much more difficult to find. We're now including all SVG icons into the style guide, even if it's introduced by a Workarea plugin.

### Issues

- [ECOMMERCE-5446](https://jira.tools.weblinc.com/browse/ECOMMERCE-5446)

### Pull Requests

- [3159](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3159)

- [e51c8ffa74f94134d60682482de36247f780e98b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e51c8ffa74f94134d60682482de36247f780e98b)
- [1236e7e11dfe0c01b4d8c973a440155ca6071289](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1236e7e11dfe0c01b4d8c973a440155ca6071289)

## Fix date-specific test failure

Due to the use of `3.months` as our `order_expiration_period`, some tests failed on February 28th specifically because they were expiring orders days before the test had expected them to. We've updated this config setting to be the more specific `90
  days`, which fluctuates less often.

### Issues

- [ECOMMERCE-5810](https://jira.tools.weblinc.com/browse/ECOMMERCE-5810)

### Pull Requests

- [3180](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3180)

- [7b5ad59e4091a3645359335d12b9e1b451999dac](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7b5ad59e4091a3645359335d12b9e1b451999dac)

