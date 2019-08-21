---
title: Workarea 3.1.9
excerpt: Adds an explicit dependency on the Mongo Ruby Driver to Workarea Core to avoid using version 2.5, which was recently released and is incompatible with Workarea.
---

# Workarea 3.1.9

## Avoids Using Mongo Ruby Driver 2.5

Adds an explicit dependency on the [Mongo Ruby Driver](https://rubygems.org/gems/mongo) to Workarea Core to avoid using version 2.5, which was recently released and is incompatible with Workarea.

### Issues

- [ECOMMERCE-5620](https://jira.tools.weblinc.com/browse/ECOMMERCE-5620)

### Pull Requests

- [3056](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3056/overview)

### Commits

- [a2a3e8af32bf130e81f93e7284649417bb35af2c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a2a3e8af32bf130e81f93e7284649417bb35af2c)
- [6053c812eeb30e387feae3cb305247fc49e5f26e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6053c812eeb30e387feae3cb305247fc49e5f26e)

## Fixes CSRF Protection for Cached Pages

Fixes Storefront pages having an invalid [authenticity token for CSRF protection](http://api.rubyonrails.org/classes/ActionController/RequestForgeryProtection.html#method-i-verify_authenticity_token) due to HTTP caching. Adds the token to the `current_user.json` response, and adds a JavaScript module to append the token (as a hidden input) to all form elements.

### Issues

- [ECOMMERCE-5583](https://jira.tools.weblinc.com/browse/ECOMMERCE-5583)

### Pull Requests

- [3040](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3040/overview)

### Commits

- [e199acc3c32d7916b786ea9e93949394ea683c8f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e199acc3c32d7916b786ea9e93949394ea683c8f)
- [dbd6f90b62f0a5b76096bbb9f1539388fd4248ed](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/dbd6f90b62f0a5b76096bbb9f1539388fd4248ed)
- [4c6b8f18e5c5fe946ccc6151ccdea20316d4e775](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4c6b8f18e5c5fe946ccc6151ccdea20316d4e775)

## Fixes Unused Translations Included in JavaScript

Adds a default configuration for Rails i18n to Workarea Core. Configures exactly one locale, _en_, so that additional, unused translation are not included in Production JavaScript. Prior to this change, apps that did not configure Rails i18n were serving extremely large JavaScript files due to the inclusion of unused translations.

### Issues

- [ECOMMERCE-5632](https://jira.tools.weblinc.com/browse/ECOMMERCE-5632)

### Pull Requests

- [3064](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3064/overview)

### Commits

- [38ec4a96bf80c62103a5838be80890f0543a691d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/38ec4a96bf80c62103a5838be80890f0543a691d)
- [8ce9118be1c308854a13e8934f38c73d9d067f68](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8ce9118be1c308854a13e8934f38c73d9d067f68)
- [4c6b8f18e5c5fe946ccc6151ccdea20316d4e775](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4c6b8f18e5c5fe946ccc6151ccdea20316d4e775)

## Fixes JavaScript Module Re-Initialization in Checkout

Fixes JavaScript modules not being initialized on a new DOM fragment inserted asynchronously into the checkout UI.

### Issues

- [ECOMMERCE-5616](https://jira.tools.weblinc.com/browse/ECOMMERCE-5616)

### Pull Requests

- [3047](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3047/overview)

### Commits

- [1d40424d14de1c8ab62ef2140c54cef3affd9757](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1d40424d14de1c8ab62ef2140c54cef3affd9757)
- [e77519122d663480a0de6cf6bd39c77783a17700](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e77519122d663480a0de6cf6bd39c77783a17700)
- [4c6b8f18e5c5fe946ccc6151ccdea20316d4e775](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4c6b8f18e5c5fe946ccc6151ccdea20316d4e775)

## Fixes Duplicate DOM IDs on Admin Dashboards

Fixes duplicate DOM IDs in two Admin dashboard partials.

### Issues

- [ECOMMERCE-5618](https://jira.tools.weblinc.com/browse/ECOMMERCE-5618)

### Pull Requests

### Commits

- [79579138c56a97a056e923593ce270bfc9391442](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/79579138c56a97a056e923593ce270bfc9391442)

## Fixes Admin Insights Charts Not Rendering

Fixes an issue preventing some insights charts from rendering in the Admin.

### Issues

- [ECOMMERCE-5540](https://jira.tools.weblinc.com/browse/ECOMMERCE-5540)

### Pull Requests

- [3014](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3014/overview)

### Commits

- [e8d1f2c46418ef5ee3733e1814f2a1b94caee6b6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e8d1f2c46418ef5ee3733e1814f2a1b94caee6b6)
- [25fcd66cb48d9c2350c5855a9f0cb26673eb0684](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/25fcd66cb48d9c2350c5855a9f0cb26673eb0684)

## Fixes Admin Toolbar Page Jump

Fixes the "jump" that occurs in the Storefront when the Admin toolbar loads after a delay. Reserves space for the toolbar before it is loaded to prevent the repaint.

### Issues

- [ECOMMERCE-5593](https://jira.tools.weblinc.com/browse/ECOMMERCE-5593)

### Pull Requests

- [3037](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3037/overview)

### Commits

- [71e01fb49f74391e7e011df3090ab7aecb5df267](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/71e01fb49f74391e7e011df3090ab7aecb5df267)
- [9f4453257c2544e0b8da1e6b764c02a6a8418978](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9f4453257c2544e0b8da1e6b764c02a6a8418978)
- [b78b0d2c53efda0109d4afd77e6c6d76e431fb65](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b78b0d2c53efda0109d4afd77e6c6d76e431fb65)

## Fixes Countries Mongoid Extension Not Loaded

Explicitly loads the [Countries Mongoid Extensions](https://github.com/hexorx/countries/blob/master/lib/countries/mongoid.rb) when Workarea is loaded to prevent an exception being raised in some circumstances where the library is not loaded when it's needed.

### Issues

- [ECOMMERCE-5582](https://jira.tools.weblinc.com/browse/ECOMMERCE-5582)

### Pull Requests

- [3033](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3033/overview)

### Commits

- [6102b0df23963bd57a55a84d201b9975498d733b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6102b0df23963bd57a55a84d201b9975498d733b)
- [a082018d9c380ab3e668c3792ecb25bd3f57e746](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a082018d9c380ab3e668c3792ecb25bd3f57e746)
- [b78b0d2c53efda0109d4afd77e6c6d76e431fb65](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b78b0d2c53efda0109d4afd77e6c6d76e431fb65)

## Disables Autocomplete for Storefront Password Fields

Disables the native autocomplete feature on all Storefront password fields to prevent leaking sensitive information. This change supports PCI compliance. In cloud environments, the web application firewall also performs this function for redundancy.

### Issues

- [ECOMMERCE-5590](https://jira.tools.weblinc.com/browse/ECOMMERCE-5590)

### Pull Requests

- [3035](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3035/overview)

### Commits

- [b0478bed84082e29a8b41ab546060dc0609db66d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b0478bed84082e29a8b41ab546060dc0609db66d)
- [4e8b9c306153e78404b4fca06e870c6621c0e924](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4e8b9c306153e78404b4fca06e870c6621c0e924)
- [b78b0d2c53efda0109d4afd77e6c6d76e431fb65](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b78b0d2c53efda0109d4afd77e6c6d76e431fb65)

## Improves Extensibility of Storefront Address Forms

Changes a DOM query and adds a wrapping DOM element to allow for easier extension of address form markup in the Storefront.

### Issues

- [ECOMMERCE-5394](https://jira.tools.weblinc.com/browse/ECOMMERCE-5394)

### Pull Requests

- [3054](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3054/overview)

### Commits

- [0eb6e8945d45081c519bf9f5d44455b3534b2f11](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0eb6e8945d45081c519bf9f5d44455b3534b2f11)
- [83c1776ba99ab7bab85e2dfd075b45e291720db8](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/83c1776ba99ab7bab85e2dfd075b45e291720db8)
- [ed195461603adf3fb1a6a37157561f6a2a94e471](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ed195461603adf3fb1a6a37157561f6a2a94e471)
- [4c6b8f18e5c5fe946ccc6151ccdea20316d4e775](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4c6b8f18e5c5fe946ccc6151ccdea20316d4e775)

## Adds Admin Pricing Skus Append Points

Adds append points for pricing skus in the Admin.

### Issues

- [ECOMMERCE-5614](https://jira.tools.weblinc.com/browse/ECOMMERCE-5614)

### Pull Requests

- [3045](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3045/overview)

### Commits

- [b1c060e40d2ed627141fab1464abc1844c4a35f4](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b1c060e40d2ed627141fab1464abc1844c4a35f4)
- [aa052640aa8339673ef33107f648324e59e85afd](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/aa052640aa8339673ef33107f648324e59e85afd)
- [4c6b8f18e5c5fe946ccc6151ccdea20316d4e775](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4c6b8f18e5c5fe946ccc6151ccdea20316d4e775)

## Styles HTML Address Elements

Adds default styles to the Admin and Storefront for HTML _address_ elements. Removes italic styling applied by most browsers.

### Issues

- [ECOMMERCE-5595](https://jira.tools.weblinc.com/browse/ECOMMERCE-5595)

### Commits

- [7dd376245add81c94e9b4366e1a4b94c5a5e9113](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7dd376245add81c94e9b4366e1a4b94c5a5e9113)

