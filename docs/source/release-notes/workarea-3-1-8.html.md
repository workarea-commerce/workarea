---
title: Workarea 3.1.8
excerpt: Implements + and - instance methods on SwappableList to ensure += and -= each return a SwappableList rather than an Array. Some plugin code in Production already assumes this behavior, so this change updates the API to match that expectation.
---

# Workarea 3.1.8

## Adds Concatenation & Difference Methods to Swappable List

Implements `+` and `-` instance methods on `SwappableList` to ensure `+=` and `-=` each return a `SwappableList` rather than an `Array`. Some plugin code in Production already assumes this behavior, so this change updates the API to match that expectation.

Although unlikely, **you may have application code that depends on the previous behavior**. You may want to search your application source for these methods on `SwappableList` to see how they are used.

### Issues

- [ECOMMERCE-5531](https://jira.tools.weblinc.com/browse/ECOMMERCE-5531)

### Pull Requests

- [2998](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2998/overview)

### Commits

- [53a6f5c971c8730f97bffdc71194c9e15cd8a18b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/53a6f5c971c8730f97bffdc71194c9e15cd8a18b)
- [67b6b2baa645622c10bc66d42885c3bf678c27c4](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/67b6b2baa645622c10bc66d42885c3bf678c27c4)
- [057fac6672fbe928b8828118a3af648de905e0cb](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/057fac6672fbe928b8828118a3af648de905e0cb)

## Fixes Logging Out in Safari

Changes the HTTP method used to log out of the Storefront, resolving a race condition in Safari.

### Issues

- [ECOMMERCE-5476](https://jira.tools.weblinc.com/browse/ECOMMERCE-5476)

### Pull Requests

- [3010](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3010/overview)

### Commits

- [42ea5c14462a6bb148fb43f93a8f6d80f40cb083](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/42ea5c14462a6bb148fb43f93a8f6d80f40cb083)
- [c024b92ce4ae1f639899105e7786bec81c711fa8](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c024b92ce4ae1f639899105e7786bec81c711fa8)
- [dd1dc2673b3711c2327edeed08451586cc3be0a9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/dd1dc2673b3711c2327edeed08451586cc3be0a9)

## Improves View Resolution Performance

Enables ActionView resolver caching in Test environments and scales Capybara's max wait time based on number of installed plugins. These changes should reduce timeouts in Test environments caused by poor view resolution performance.

Also enables ActionView resolver caching in Development environments within the scope of a request, which improves the experience of local development, particularly when many plugins are installed.

See also [How I improved performance of my development environment by 780%](https://discourse.weblinc.com/t/how-i-improved-performance-of-my-development-environment-by-780).

### Issues

- [ECOMMERCE-5532](https://jira.tools.weblinc.com/browse/ECOMMERCE-5532)

### Pull Requests

- [3000](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3000/overview)

### Commits

- [a6a6dd3a38c935425e717a1f0819c70822a428ce](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a6a6dd3a38c935425e717a1f0819c70822a428ce)
- [0464c07cc70039c98a4e8a169298ca7d59c90e77](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0464c07cc70039c98a4e8a169298ca7d59c90e77)
- [dd1dc2673b3711c2327edeed08451586cc3be0a9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/dd1dc2673b3711c2327edeed08451586cc3be0a9)

## Fixes Client Side Validation for Checkout

Requires additional methods from the jQuery Validation Plugin library that were unintentionally omitted from Workarea since version 3.0.0. Fixes some client side validations and JavaScript errors in checkout.

### Issues

- [ECOMMERCE-5533](https://jira.tools.weblinc.com/browse/ECOMMERCE-5533)

### Pull Requests

- [3011](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3011/overview)

### Commits

- [9111727f9c945b6c83eb5228565fad6f65c8eca1](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9111727f9c945b6c83eb5228565fad6f65c8eca1)
- [73c4d52895bbf105c8b13a8ca8bd793ba5747c40](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/73c4d52895bbf105c8b13a8ca8bd793ba5747c40)
- [dd1dc2673b3711c2327edeed08451586cc3be0a9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/dd1dc2673b3711c2327edeed08451586cc3be0a9)

## Fixes Storefront Region Selects

Fixes region selects within Storefront address forms by changing the implementation used to hide irrelevant region options. The previous implementation was not portable across browsers.

### Issues

- [ECOMMERCE-5516](https://jira.tools.weblinc.com/browse/ECOMMERCE-5516)

### Pull Requests

- [2984](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2984/overview)

### Commits

- [a6c4159ec3adffd4d67d47b928a3fb6ddb93b789](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a6c4159ec3adffd4d67d47b928a3fb6ddb93b789)
- [bdd5668dc535ac7ea44687fef21b89788f23a375](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/bdd5668dc535ac7ea44687fef21b89788f23a375)
- [1f1c8b6f31cb7178d3c931f84767eaaf88856510](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1f1c8b6f31cb7178d3c931f84767eaaf88856510)

## Fixes Bulk Actions Not Being Marked Completed

Ensures bulk actions are marked completed so the Admin does not incorrectly show them as in progress.

### Issues

- [ECOMMERCE-5521](https://jira.tools.weblinc.com/browse/ECOMMERCE-5521)

### Pull Requests

- [2988](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2988/overview)

### Commits

- [3a3227694788d4d71e2768c6d4c4772b82130fe3](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/3a3227694788d4d71e2768c6d4c4772b82130fe3)
- [9a92f9a30a18c5cf86d2c051579dd2fe2a596139](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9a92f9a30a18c5cf86d2c051579dd2fe2a596139)
- [1f1c8b6f31cb7178d3c931f84767eaaf88856510](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1f1c8b6f31cb7178d3c931f84767eaaf88856510)

## Fixes Error Messages for Bulk Actions

Fixes Admin error messages for bulk actions, which could display despite a valid selection.

### Issues

- [ECOMMERCE-5547](https://jira.tools.weblinc.com/browse/ECOMMERCE-5547)

### Pull Requests

- [3018](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3018/overview)

### Commits

- [7d2a78ed6caeac24909c092c17ce6d7f3558fb87](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7d2a78ed6caeac24909c092c17ce6d7f3558fb87)
- [767cb9c9165f3fe0840e3505e8510977e5e305ef](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/767cb9c9165f3fe0840e3505e8510977e5e305ef)
- [8abbba7e7d8d20496903da996a67b7656e163ca2](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8abbba7e7d8d20496903da996a67b7656e163ca2)

## Fixes Test Reporter Exception on Failing Decorated Tests

Fixes an exception raised during a test run from an application when a test decorated by a plugin fails.

### Issues

- [ECOMMERCE-5514](https://jira.tools.weblinc.com/browse/ECOMMERCE-5514)

### Pull Requests

- [2989](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2989/overview)

### Commits

- [b7e8d86a6f01d399d030ae31a4cc0f59987cf014](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b7e8d86a6f01d399d030ae31a4cc0f59987cf014)
- [94107b95c7820fdf8cdce68179912ddecbf23fb1](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/94107b95c7820fdf8cdce68179912ddecbf23fb1)
- [1f1c8b6f31cb7178d3c931f84767eaaf88856510](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1f1c8b6f31cb7178d3c931f84767eaaf88856510)

## Fixes `Workarea.with_config` for Multi Site Applications

Fixes `Workarea.with_config` when a plugin has extended `Workarea.config`. This is particularly a problem for applications using Workarea Multi Site.

### Issues

- [ECOMMERCE-5523](https://jira.tools.weblinc.com/browse/ECOMMERCE-5523)

### Pull Requests

- [2997](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2997/overview)

### Commits

- [d5367b3a74c9ada79e09d1680966f6bf68967a98](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d5367b3a74c9ada79e09d1680966f6bf68967a98)
- [3da1cd9f69b950642ea1751a2c86cd65e3771718](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/3da1cd9f69b950642ea1751a2c86cd65e3771718)
- [057fac6672fbe928b8828118a3af648de905e0cb](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/057fac6672fbe928b8828118a3af648de905e0cb)

## Fixes Canonical URLs in Storefront

Updates all canonical URL metadata in the Storefront to ensure the correct protocol is used and the domain name is included. This conforms to [guidelines published by Google](https://support.google.com/webmasters/answer/139066).

### Issues

- [ECOMMERCE-5484](https://jira.tools.weblinc.com/browse/ECOMMERCE-5484)

### Pull Requests

- [2999](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2999/overview)

### Commits

- [5faaf3e847cc19e48aee553bea5086525a8f4a51](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5faaf3e847cc19e48aee553bea5086525a8f4a51)
- [0adab35b7b707b179056645cd49b5de365e9f28c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0adab35b7b707b179056645cd49b5de365e9f28c)
- [dd1dc2673b3711c2327edeed08451586cc3be0a9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/dd1dc2673b3711c2327edeed08451586cc3be0a9)

## Renames Categories Seeds Filename

Renames the categories seeds filename to match the class name, which fixes an issue when decorating the class.

### Issues

- [ECOMMERCE-5517](https://jira.tools.weblinc.com/browse/ECOMMERCE-5517)

### Pull Requests

- [2983](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2983/overview)

### Commits

- [5a9638c9ef8d206eaac094541ecc112ec7ac64b5](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5a9638c9ef8d206eaac094541ecc112ec7ac64b5)
- [e4de68066345c8e872d54b64949c70766b2fc126](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e4de68066345c8e872d54b64949c70766b2fc126)
- [1f1c8b6f31cb7178d3c931f84767eaaf88856510](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1f1c8b6f31cb7178d3c931f84767eaaf88856510)

## Fixes Typo in Admin Translation

Fixes a typo within the Admin's _en_ locale file.

### Issues

- [ECOMMERCE-5539](https://jira.tools.weblinc.com/browse/ECOMMERCE-5539)

### Pull Requests

- [3013](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3013/overview)

### Commits

- [7940a8f44760670fadf26f9b70624f6e18a55c87](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7940a8f44760670fadf26f9b70624f6e18a55c87)
- [c2bb8f00de7821fd40c7191048d5c4369a49c342](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c2bb8f00de7821fd40c7191048d5c4369a49c342)
- [dd1dc2673b3711c2327edeed08451586cc3be0a9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/dd1dc2673b3711c2327edeed08451586cc3be0a9)

## Adds HTML Attributes to WYSIWYG Configuration

Configures Admin WYSIWYG editors to allow `alt`, `href`, and `style` attributes by default.

### Issues

- [ECOMMERCE-5445](https://jira.tools.weblinc.com/browse/ECOMMERCE-5445)

### Pull Requests

- [3002](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3002/overview)

### Commits

- [08e4531045cdfdcbb567b0a5daa65b6f25eaa62f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/08e4531045cdfdcbb567b0a5daa65b6f25eaa62f)
- [2e72aaa67b77002370c2ba8d403984c89c9eb373](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2e72aaa67b77002370c2ba8d403984c89c9eb373)
- [057fac6672fbe928b8828118a3af648de905e0cb](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/057fac6672fbe928b8828118a3af648de905e0cb)

## Adds VCR Cassette Persister Support for Nested Cassettes

Updates Workarea's VCR cassette persister to support cassettes within subdirectories, like VCR's default cassette persister does.

### Issues

- [ECOMMERCE-5528](https://jira.tools.weblinc.com/browse/ECOMMERCE-5528)

### Pull Requests

- [2995](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2995/overview)

### Commits

- [6449a929ebc7966f77cc2200ddb5d2b5aeadb6cd](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6449a929ebc7966f77cc2200ddb5d2b5aeadb6cd)
- [ae62bccfb832c626425bbce97ba3f8060fafc411](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ae62bccfb832c626425bbce97ba3f8060fafc411)
- [057fac6672fbe928b8828118a3af648de905e0cb](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/057fac6672fbe928b8828118a3af648de905e0cb)

## Expands DOM Query within Checkout Shipping Services Module

Modifies the Storefront JavaScript module, `WORKAREA.checkoutShippingServices`, adding an additional DOM hook that can be leveraged by applications and plugins.

### Issues

- [ECOMMERCE-5525](https://jira.tools.weblinc.com/browse/ECOMMERCE-5525)

### Pull Requests

- [3008](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3008/overview)

### Commits

- [4bc11304f1532f00fc4a1d7e11e129375a670e21](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4bc11304f1532f00fc4a1d7e11e129375a670e21)
- [92a88f52d889546db558ed4294ec0b775ff77baa](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/92a88f52d889546db558ed4294ec0b775ff77baa)
- [dd1dc2673b3711c2327edeed08451586cc3be0a9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/dd1dc2673b3711c2327edeed08451586cc3be0a9)

