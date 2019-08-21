---
title: Workarea 3.1.13
excerpt:  Iterate through all shipping records related to the checkout and save/validate their information. Although out-of-box we only support a single shipping record, this allows plugins like split-shipping to work without diving too far into checkout decor
---

# Workarea 3.1.13

## Persist and validate ability to ship when updating checkout addresses

Iterate through all shipping records related to the checkout and save/validate their information. Although out-of-box we only support a single shipping record, this allows plugins like split-shipping to work without diving too far into checkout decoration.

### Issues

- [ECOMMERCE-5705](https://jira.tools.weblinc.com/browse/ECOMMERCE-5705)

### Pull Requests

- [3117](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3117/overview)

### Commits

- [55ad263529c6cc562e04338232408ecc02363b5e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/55ad263529c6cc562e04338232408ecc02363b5e)

## Split cookie data on the correct delimiter to create key/value pairs

The `WORKAREA.cookie.read()` method takes a given key and returns the value of that key in the `document.cookie` string. This string, which delimits key/value pairs with a semicolon and the difference between a key & value with an equals sign, is at some point split on the character `=`, which in a URL could in theory exist within query string parameters. Instead of splitting on every occurrence of `=`, we're now only splitting on its first occurrence and preserving the rest of the string as its value.

### Issues

- [ECOMMERCE-4763](https://jira.tools.weblinc.com/browse/ECOMMERCE-4763)

### Pull Requests

- [3137](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3137/overview)

### Commits

- [a83dc27ca2cc8cfa4a8a32ba778c1a9d0909de13](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a83dc27ca2cc8cfa4a8a32ba778c1a9d0909de13)

## Generate contents of first release in changelog generator Rake task

When generating a new plugin, the `changelog` task now considers all changes, from the initial commit to the current, as the initial release. This addresses an issue wherein if no tags were ever created on the plugin's Git repo, the initial changelog entry would be blank.

### Issues

- [ECOMMERCE-4853](https://jira.tools.weblinc.com/browse/ECOMMERCE-4853)

### Pull Requests

- [3106](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3106/overview)

### Commits

- [04c727fce480d07b084039e7f2a1a6d06dac8da9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/04c727fce480d07b084039e7f2a1a6d06dac8da9)

## New action for rendering product details asynchronously

Previous versions of the platform rendered a different template on the `storefront/products#show` action when requested asynchronously using XmlHttpRequest. Rather than overload the show action by returning out of it prematurely, causing issues downstream when other plugins wish to decorate the action, we're displaying the product details partial for a given template in its own action, called `storefront/products#details` which is requested asynchronously instead of the original show action for products. This is aimed to reduce complexity in other product template plugins, as well as address a number of issues with quickview, package products, and other plugins that modify (or build on top of) product templates.

### Issues

- [ECOMMERCE-5663](https://jira.tools.weblinc.com/browse/ECOMMERCE-5663)

### Pull Requests

- [3129](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3129/overview)

## Fix configuration for sending emails in a background job

ActionMailer uses ActiveJob to send emails in the background, and out-of-box we were not configuring it to use Sidekiq. We're now setting ActiveJob's queue\_adapter in the platform, so ActiveJob always uses Sidekiq by default rather than the "async" adapter.

### Issues

- [ECOMMERCE-5724](https://jira.tools.weblinc.com/browse/ECOMMERCE-5724)

### Pull Requests

- [3129](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3129/overview)

## Add append point to alt images on generic product template

Add the `storefront.product_details_alt_images` append point to the end of the generic product template, and within the `.product-details__alt-images` element. This will be used by the product videos plugin to append videos as a thumbnail.

### Issues

- [ECOMMERCE-5720](https://jira.tools.weblinc.com/browse/ECOMMERCE-5720)

### Pull Requests

- [3127](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3127/overview)

### Commits

- [28140f1b786ec905663745786c8b68e2c476d199](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/019d7a1cc50e0b59a6f08f2fa7cbb3c4025e0e13)

## Add class modifier for block type to .content-block

The `.content-block` block now includes a modifier class for determining the content block type. For example, the block type class for a "rich text" content block might be `.content-block--rich-text`.

### Issues

- [ECOMMERCE-5730](https://jira.tools.weblinc.com/browse/ECOMMERCE-5730)

### Pull Requests

- [3132](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3132/overview)
- [3138](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3138/overview)

### Commits

- [28140f1b786ec905663745786c8b68e2c476d199](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/28140f1b786ec905663745786c8b68e2c476d199)
- [3af4bbbb45c1af30c461b0f4ce6c8155acbfb786](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/3af4bbbb45c1af30c461b0f4ce6c8155acbfb786)

