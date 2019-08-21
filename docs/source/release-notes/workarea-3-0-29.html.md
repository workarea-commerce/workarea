---
title: Workarea 3.0.29
excerpt:  The address fields partial was not translated out-of-box, we're now adding the translations from address fields in the storefront into the admin fields partial 
---

# Workarea 3.0.29

## Translate the address fields partial

The address fields partial was not translated out-of-box, we're now adding the translations from address fields in the storefront into the admin fields partial

### Issues

- [ECOMMERCE-5781](https://jira.tools.weblinc.com/browse/ECOMMERCE-5781)

### Pull Requests

- [3175](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3175)

### Commits

- [998b9d32b1a16d34e1b9475bb9612d05bc7a8c0c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/998b9d32b1a16d34e1b9475bb9612d05bc7a8c0c)

## Fix potential cookie overflow error in admin

When viewing admin pages with a lot of text on them, clicking the "Help" button could potentially have caused a cookie overflow error if the admin's session expired at the same time as they clicked the button. This is because the amount of content in the `like_text` param in the URL is too large for the `:return_to` session value (stored in a client-side cookie). We introduced a new configuration value named `return_to_url_max_length` that prescribes the amount of characters in a `:return_to` URL. This prevents help URLs from being too long for storage in a client-side cookie.

### Issues

- [ECOMMERCE-5387](https://jira.tools.weblinc.com/browse/ECOMMERCE-5387)

### Pull Requests

- [3170](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3170)

### Commits

- [2c42f23199cce8848dcc4735fb95e743899e05b4](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2c42f23199cce8848dcc4735fb95e743899e05b4)

## Include plugin SVGs on style guide

We weren't including new SVG icons introduced by plugins in style guides. This made finding all the icons at your disposal in a given implementation much more difficult to find. We're now including all SVG icons into the style guide, even if it's introduced by a Workarea plugin.

### Issues

- [ECOMMERCE-5446](https://jira.tools.weblinc.com/browse/ECOMMERCE-5446)

### Pull Requests

- [3159](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3159)

### Commits

- [e51c8ffa74f94134d60682482de36247f780e98b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e51c8ffa74f94134d60682482de36247f780e98b)
- [1236e7e11dfe0c01b4d8c973a440155ca6071289](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1236e7e11dfe0c01b4d8c973a440155ca6071289)

## Fix date-specific test failure

Due to the use of `3.months` as our `order_expiration_period`, some tests failed on February 28th specifically because they were expiring orders days before the test had expected them to. We've updated this config setting to be the more specific `90
  days`, which fluctuates less often.

### Issues

- [ECOMMERCE-5810](https://jira.tools.weblinc.com/browse/ECOMMERCE-5810)

### Pull Requests

- [3180](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3180)

### Commits

- [7b5ad59e4091a3645359335d12b9e1b451999dac](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7b5ad59e4091a3645359335d12b9e1b451999dac)

