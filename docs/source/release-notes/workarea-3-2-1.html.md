---
title: Workarea 3.2.1
excerpt: Updates Workarea::AutoexpireCacheRedis, replacing API calls that were removed in the latest version of the Redis Ruby client. Ruby dependency changes in Workarea 3.2 are causing Bundler to resolve to a newer version of the Redis client, which introduc
---

# Workarea 3.2.1

## Fixes Exception When Using Latest Redis Client

Updates `Workarea::AutoexpireCacheRedis`, replacing API calls that were removed in the latest version of the Redis Ruby client. Ruby dependency changes in Workarea 3.2 are causing Bundler to resolve to a newer version of the Redis client, which introduced the problem. Seeding an environment where caching is enabled was raising an exception.

### Issues

- [ECOMMERCE-5685](https://jira.tools.weblinc.com/browse/ECOMMERCE-5685)

### Pull Requests

- [3099](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3099/overview)

### Commits

- [8cca5e7913662446c15cf626b079c3ecbcef10f1](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8cca5e7913662446c15cf626b079c3ecbcef10f1)
- [68d6572f3d9714c09eb8fcf8409e05ead379e33d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/68d6572f3d9714c09eb8fcf8409e05ead379e33d)

## Fixes Multiple CSRF Authenticity Tokens

Fixes Storefront forms containing multiple CSRF authenticity token fields. A previous fix, [Fixes CSRF Protection for Cached Pages](workarea-3-0-23.html#fixes-csrf-protection-for-cached-pages), introduced the issue. Modifies Storefront JavaScript module `WORKAREA.authenticityToken`.

### Issues

- [ECOMMERCE-5686](https://jira.tools.weblinc.com/browse/ECOMMERCE-5686)

### Pull Requests

- [3101](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3101/overview)

### Commits

- [dcd1ca354d0cb32d7213beb8b5f5d409c1b0db93](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/dcd1ca354d0cb32d7213beb8b5f5d409c1b0db93)
- [3f64623ddf68adc1755cc97586adcef366ceafe0](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/3f64623ddf68adc1755cc97586adcef366ceafe0)

## Fixes ImageOptim Processor Not Optimizing Images

Fixes `Workarea:ImageOptimProcessor`, which was not optimizing product images and content assets due to an oversight in its implementation.

### Issues

- [ECOMMERCE-5653](https://jira.tools.weblinc.com/browse/ECOMMERCE-5653)

### Pull Requests

- [3091](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3091/overview)

### Commits

- [4b66c7b12009fb8e9b49d3a63b1fe89bdd40a157](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4b66c7b12009fb8e9b49d3a63b1fe89bdd40a157)
- [77151cf07a9dadd929a033abeab4b8b3d6d43e55](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/77151cf07a9dadd929a033abeab4b8b3d6d43e55)

## Fixes Admins Seeds Password in Non-Development Environments

Fixes a password in the admins seeds to conform to the [Workarea 3.2.0 admin password requirements](workarea-3-2-0.html#changes-password-requirements-for-admins). This oversight was causing an exception to raise when seeding non-development environments.

### Issues

- [ECOMMERCE-5682](https://jira.tools.weblinc.com/browse/ECOMMERCE-5682)

### Pull Requests

- [3096](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3096/overview)

### Commits

- [8a2cf06f4f1e9fbfe2a68eeb8220d3efdbd0a610](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8a2cf06f4f1e9fbfe2a68eeb8220d3efdbd0a610)
- [1c941424a411231dcb99c7704a0265a768db0b2d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1c941424a411231dcb99c7704a0265a768db0b2d)

## Fixes Intermittent Exception in Discounts Seeds

Updates discounts seeds to ensure the product used for the free gift discount has at least one variant. Fixes an exception raising intermittently during seeding.

### Issues

- [ECOMMERCE-5684](https://jira.tools.weblinc.com/browse/ECOMMERCE-5684)

### Pull Requests

- [3097](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3097/overview)

### Commits

- [ff13b602a5f3a4de06c7c223590a748863f60073](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ff13b602a5f3a4de06c7c223590a748863f60073)
- [b33574d3b7963654beaa44afe2a431642b7750a5](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b33574d3b7963654beaa44afe2a431642b7750a5)

## Fixes Presentation of Saved Addresses Menu

Fixes the presentation of the saved addresses select menu in checkout, which was broken by broader changes in previous patches.

### Issues

- [ECOMMERCE-5644](https://jira.tools.weblinc.com/browse/ECOMMERCE-5644)

### Pull Requests

- [3086](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3086/overview)

### Commits

- [c3e0a975da954529492e551c5b3ad8cdc1859fce](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c3e0a975da954529492e551c5b3ad8cdc1859fce)
- [c79f19cb2f7b2619f585e49a354c02e396ac43aa](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c79f19cb2f7b2619f585e49a354c02e396ac43aa)

## Adds Validation of Product Rule Name

Adds validation for the presence of `name` on `ProductRule`. The validation was always intended, but was missing due to an oversight when the class was first defined.

### Issues

- [ECOMMERCE-5220](https://jira.tools.weblinc.com/browse/ECOMMERCE-5220)

### Pull Requests

- [3104](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3104/overview)

### Commits

- [6e670ad6418c48c228da4d67912fd93a7d5d2306](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6e670ad6418c48c228da4d67912fd93a7d5d2306)
- [e2b31dabbc37b86ed6a3e92de71a1cb359fae57f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e2b31dabbc37b86ed6a3e92de71a1cb359fae57f)

## Adds Product Rule Changes to Admin Activity

Includes changes to product rules in Admin activity/timeline views.

### Issues

- [ECOMMERCE-5024](https://jira.tools.weblinc.com/browse/ECOMMERCE-5024)

### Pull Requests

- [3089](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3089/overview)

### Commits

- [c24733eb8bf256d83420a985c623f37cfc6d4776](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c24733eb8bf256d83420a985c623f37cfc6d4776)
- [d709c8f81db1950b5a5c8eb7e1f6bc77c00d3c90](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d709c8f81db1950b5a5c8eb7e1f6bc77c00d3c90)

## Adds Support for Improved Invalid State

Within the Storefront, re-validates the fields within a form when the form is submitted. This ensures _all_ invalid fields receive a `--invalid` modifier. Prior to this change, only recently focused fields would receive this modifier. This change improves the “invalid” state of a form when an application is styling this state. The platform does not style this state by default.

### Issues

- [ECOMMERCE-5639](https://jira.tools.weblinc.com/browse/ECOMMERCE-5639)

### Pull Requests

- [3082](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3082/overview)

### Commits

- [2d0164f690c0947005a8ffd2ead30875b475714e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2d0164f690c0947005a8ffd2ead30875b475714e)
- [9c5b56dfda3830750221938ad04e6f60abe91cd9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9c5b56dfda3830750221938ad04e6f60abe91cd9)

## Adds Support for Skipping External Service Connections

Adds Core config `Workarea.config.skip_service_connections`, which, when `true`, allows developers to initialize the Rails app when external services (for example: Elasticsearch, Mongoid, and Redis) are not available. This may be useful if you want to compile assets or run a task that requires initializing the application, but does not utilize external services.

By default, the value of this config depends on the value of the environment variable `WORKAREA_SKIP_SERVICES`. Set that variable to `'true'` within the environment to prevent the application from making external service connections.

### Issues

- [ECOMMERCE-5648](https://jira.tools.weblinc.com/browse/ECOMMERCE-5648)

### Pull Requests

- [3083](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3083/overview)

### Commits

- [d8159ffa761ab8705fb14245994ba7f5abc727e7](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d8159ffa761ab8705fb14245994ba7f5abc727e7)
- [b24980858d002a0eba12d95dfaccdacf52c52182](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b24980858d002a0eba12d95dfaccdacf52c52182)

## Adds Configurations for Workarea Hosting to New Applications

Adds additional environment-specific configurations to the app template, which is used to create new Workarea applications. The additions configure new applications appropriately for [Workarea Hosting](https://developer.workarea.com/hosting/) environments.

Adds configuration of caching and mail delivery to the existing _production_ environment-specific configuration file for new applications.

Adds to new applications the additional environment-specific configuration files _config/environments/staging.rb_ and _config/environments/qa.rb_, whose default contents duplicate the _production_ configuration. The presence of these files also creates additional [Rails environments](http://guides.rubyonrails.org/configuring.html#creating-rails-environments).

### Issues

- [ECOMMERCE-5654](https://jira.tools.weblinc.com/browse/ECOMMERCE-5654)

### Pull Requests

- [3090](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3090/overview)

### Commits

- [6352e3319576b123e7ece3d32295a2bb4d71736c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6352e3319576b123e7ece3d32295a2bb4d71736c)
- [9b548706f2c11aa6dcd0f6e558ce1e625ea9fd9a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9b548706f2c11aa6dcd0f6e558ce1e625ea9fd9a)

## Adds “Checkout Payment Top” Append Point to Storefront

Adds a new append point to the Storefront checkout payment step, because existing append points are included conditionally and are therefore not always present.

### Issues

- [ECOMMERCE-5655](https://jira.tools.weblinc.com/browse/ECOMMERCE-5655)

### Pull Requests

- [3094](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3094/overview)

### Commits

- [afa82c60991af4dde888608475076166b640f9a9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/afa82c60991af4dde888608475076166b640f9a9)
- [ff0aec04cf013862f91b0e2059072ed40a7a5373](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ff0aec04cf013862f91b0e2059072ed40a7a5373)
