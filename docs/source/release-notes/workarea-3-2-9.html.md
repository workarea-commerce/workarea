---
title: Workarea 3.2.9
excerpt:  In the megabuild, a Rails application that depends on every plugin in our ecosystem and tested against before every release, impersonation was causing some unexpected test failures related to the order of firing before_action callbacks. To remedy thi
---

# Workarea 3.2.9

## Move Impersonation to Base Controller to Prevent Unexpected Behavior

In the megabuild, a Rails application that depends on every plugin in our ecosystem and tested against before every release, impersonation was causing some unexpected test failures related to the order of firing `before_action` callbacks. To remedy this issue, we've moved impersonation to `Workarea::ApplicationController` and configure it based on the session with `prepend_before_action`. This ensures that impersonation is configured before any other callbacks on the controller or action, and prevents random errors in your build.

### Issues

- [ECOMMERCE-6078](https://jira.tools.weblinc.com/browse/ECOMMERCE-6078)

### Pull Requests

- [3409](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3409/overview)

### Commits

- [be33b52b124cf3276d6bdfe13bfd9f13ea9ceb43](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/be33b52b124cf3276d6bdfe13bfd9f13ea9ceb43)

## Fix Duplication of Release Names in Primary Nav

When on a current release and viewing the primary navigation in admin, release names are no longer duplicated as a result of the current release and query for all releases not checking for uniqueness before rendering to the page. We're now ensuring releases are unique by ID before showing them onto the page.

### Issues

- [ECOMMERCE-5883](https://jira.tools.weblinc.com/browse/ECOMMERCE-5883)

### Pull Requests

- [3392](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3392/overview)

### Commits

- [a1d424c52abd58604e49910e56de815fa807efd4](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a1d424c52abd58604e49910e56de815fa807efd4)

## Fix Error When Finding Region by Geolocation on Localhost

Because `localhost` and `127.0.0.1` don't provide geolocation features, and the `Workarea::Geolocation#region` method wasn't set up to handle if a geocoder query turned up no results, some developers experienced errors when attempting to work with geolocation locally. To remedy this, we're now checking whether the Geocoder request didn't turn up with any results, and falling back to `nil` if that's the case, since Geocoder is the fallback for geolocation HTTP headers.

### Issues

- [ECOMMERCE-6076](https://jira.tools.weblinc.com/browse/ECOMMERCE-6076)

### Pull Requests

- [3406](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3406/overview)
- [3405](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3405/overview)

### Commits

- [003045c55169a93f2c345302e9109e427272ed01](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/003045c55169a93f2c345302e9109e427272ed01)
- [981ec8d78d9a5f604d0feba16acb7d817d30a970](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/981ec8d78d9a5f604d0feba16acb7d817d30a970)

## Fix Duplicate Product IDs When Editing Products in Admin

In category featured products or product/variant details editing, it's possible to receive a duplicate ID warning when the `WORKAREA.cloneableRows` JS module activates and clones an existing row to enable editing embedded resources. As part of our larger quest to rid the admin of duplicate IDs, and much like other changes in this release, we're explicitly setting `id: nil` when using Rails form helpers in order to disable ID generation for those elements.

### Issues

- [ECOMMERCE-5864](https://jira.tools.weblinc.com/browse/ECOMMERCE-5864)

### Pull Requests

- [3390](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3390/overview)

### Commits

- [971b9a157436d41a0cf0af8c9821ed3cd55da16f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/971b9a157436d41a0cf0af8c9821ed3cd55da16f)

## Describe the Locale Icon in Admin Toolbar

Add the locale "globe" icon to the admin toolbar, and include a tooltip to explain how it works. This helps new users get used to locale-specific content in the admin.

### Issues

- [ECOMMERCE-5753](https://jira.tools.weblinc.com/browse/ECOMMERCE-5753)

### Pull Requests

- [3329](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3329/overview)

### Commits

- [d8ec53d60c758e97140e36aa040f8f5a5925772f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d8ec53d60c758e97140e36aa040f8f5a5925772f)

## Disable Support For Ruby 2.5+

After some usage of 2.5.0 and 2.5.1 by platform developers, we began to notice strange, non-determinisitic problems related to delegation. This issue revealed itself in seedingn, running tests, or within checkout steps, and the root cause was always traced back to a seemingly incorrect delegation of a method back down to a parent object.

For these reasons, we've chosen to disallow usage of Ruby 2.5+ for now, until these issues can be sufficiently addressed. This is truly an [unsolved mystery](http://i0.kym-cdn.com/entries/icons/original/000/025/550/unsolved.jpg). If you or anyone else knows the whereabouts of the original way delegation used to work in Ruby, please call the number on your screen.

### Issues

- [ECOMMERCE-5887](https://jira.tools.weblinc.com/browse/ECOMMERCE-5887)

### Pull Requests

(none)

### Commits

- [c7ccee42bcf91c38c847ddc48b4fa6dbb2b472f5](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c7ccee42bcf91c38c847ddc48b4fa6dbb2b472f5)

## Fix Syntax Error When Booting App on Ruby 2.3.0 While Skipping Scheduled Jobs

For applications that skip scheduled jobs and are also running on Ruby 2.3.0, a syntax error would occur when booting the app due to syntax that is not supported until Ruby 2.4.0. We've replaced this syntax with something that Ruby 2.3 and below can handle.

### Issues

- [ECOMMERCE-6017](https://jira.tools.weblinc.com/browse/ECOMMERCE-6017)

### Pull Requests

- [3365](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3365/overview)

### Commits

- [beb60b327a0bf25ca746721d9d762eb927ea5713](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/beb60b327a0bf25ca746721d9d762eb927ea5713)

## Add New Content Presets Asynchronously

When adding a new content preset in the middle of a workflow, the page refresh used to break you out of the workflow and prevent you from finishing. We're now submitting this tooltip form asynchronously, so it will add a new content preset for you in the background and allow admins to continue editing their workflow.

### Issues

- [ECOMMERCE-5820](https://jira.tools.weblinc.com/browse/ECOMMERCE-5820)

### Pull Requests

- [3328](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3328/overview)
- [3355](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3355/overview)

### Commits

- [e0a1b4414b4f10d14b14d1cf23622cabb8a86822](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e0a1b4414b4f10d14b14d1cf23622cabb8a86822)
- [2c05d3cb34b7fbd5ab11bf8c54086ebc9f6b802f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2c05d3cb34b7fbd5ab11bf8c54086ebc9f6b802f)

## Lock Down Rufus-scheduler

Due to a [compatibility issue in sidekiq-cron related to its usage of rufus-scheduler](https://github.com/ondrejbartas/sidekiq-cron/issues/199), errors can occur if Bundler installs a newer version of rufus-scheduler than what sidekiq-cron is expecting. To remedy this issue, we've locked down the version of rufus-scheduler to **~\> 3.4.2** in the platform until sidekiq-cron is able to [release a patch that remedies the issue](https://github.com/ondrejbartas/sidekiq-cron/pull/200).

### Issues

- [ECOMMERCE-6060](https://jira.tools.weblinc.com/browse/ECOMMERCE-6060)

### Pull Requests

- [3399](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3399/overview)

### Commits

- [1d54ae67488fea176c25732c4dd33da968732dcf](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1d54ae67488fea176c25732c4dd33da968732dcf)

## Remove "release Version X.x.x" From Changelog Task

In the `changelog.rake` task, commits starting with the message "Release version" were not omitted from the generated changelog. These commits don't represent actual changes, but rather version bumps and releases to the gem server. These commits are now omitted from future changelog generation.

### Issues

- [ECOMMERCE-6011](https://jira.tools.weblinc.com/browse/ECOMMERCE-6011)

### Pull Requests

- [3368](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3368/overview)

### Commits

- [624e30bc53a478e24ea7294bdd0aa1bf2b148e97](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/624e30bc53a478e24ea7294bdd0aa1bf2b148e97)

## Remove Content Block Field IDs to Prevent Duplicate ID Errors

In our quest to remove duplicate IDs from the admin, we discovered that content block fields can be rendered on the page multiple times, and it's difficult to tell when that will happen. By default, Rails adds IDs to its form tag helpers, but in this case we want to render the form multiple times on the page, so it's not useful for us to have those IDs. We've now removed IDs from the content block field partials that were experiencing duplicate ID errors.

### Issues

- [ECOMMERCE-5873](https://jira.tools.weblinc.com/browse/ECOMMERCE-5873)

### Pull Requests

- [3389](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3389/overview)

### Commits

- [930842818c548bcd4ef4d51ab99c390f98c579f8](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/930842818c548bcd4ef4d51ab99c390f98c579f8)

## Add Translation For Heading of Recommendations Page in the Storefront

On the user recommendations page, the "Recommendations For You" text was not an I18n translation. The raw text is now in the Storefront's locale file and renders to the view with the key `workarea.storefront.recommendations.personalized_heading`.

### Issues

- [ECOMMERCE-6004](https://jira.tools.weblinc.com/browse/ECOMMERCE-6004)

### Pull Requests

- [3341](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3341/overview)

### Commits

- [24bbb28826a67e44d271d58dd35105c4d283b22f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/24bbb28826a67e44d271d58dd35105c4d283b22f)

## Prevent Duplicate Flash Messages When Caching Enabled

With caching enabled, it's still possible for duplicate flash messages to appear on the page. Using a JavaScript Set-like object, we're now logging all flash messages to appear on the page and ensuring that none of them appear twice.

### Pull Requests

- [3312](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3312/overview)
- [3356](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3356/overview)

### Commits

- [df061927b955474dde3dc61efd2db58e0c8f1712](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/df061927b955474dde3dc61efd2db58e0c8f1712)
- [fb0e3f08982704fb99a61d1330d165e09079d357](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/fb0e3f08982704fb99a61d1330d165e09079d357)

