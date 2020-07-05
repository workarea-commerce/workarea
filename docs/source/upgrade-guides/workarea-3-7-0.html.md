---
title: Workarea 3.7.0 Upgrade Guide
excerpt: Changes requiring attention when upgrading to Workarea 3.7.0
---

# Workarea 3.7.0 Upgrade Guide

---

__Upgrading to Workarea 3.7?__ &mdash; Check out the [Workarea 3.7 Release Notes](/release-notes/workarea-3-7-0.html)

---

Before upgrading to Workarea 3.6.0, review the following changes.

## Replace Homegrown JavaScript Module System with the Stimulus Framework

### What's Changing?

The `WORKAREA` module loading system was created a long time before the standardization of JavaScript modules, language transpiling, (most) browser features, and frontend bundlers. As a result, working within the JS code is very limiting and can be difficult for new developers to catch on to. The excellent [Stimulus][] framework has also shown to work well in high-capacity environments, so Workarea has chosen to use Stimulus going forward for all new JS feature development. Also, all existing JS code has been rewritten to suit the new framework, and markup has been updated to reflect these changes. Although our markup will continue to support legacy JS modules until the next major release, all new plugin and JS feature development will be done within Stimulus.

Stimulus needs to be run within Webpack and Babel, thus you will gain all of the neat features that go along with a transpiled JavaScript language, such as automatic legacy browser support, the ability to try out new features of the language, and deep customization of how your files are loaded (for example, SVGs as base64-encoded URLs for use in CSS vs. a file path vs. inline). To create new JavaScript code in your application, you can either [decorate]() or [add]() controllers. Yup, that's right...you can now decorate your JavaScript in a similar fashion to your Ruby code, due to the way Webpack and Stimulus load controllers from file paths, and the configurable nature of Webpack allowing Workarea to supply its own gem paths in your application to search through when importing JS code.

All plugins that have been upgraded to 3.7 also include Stimulus rewrites alongside their existing legacy JS code.


### What Do You Need to Do?

If you have overridden JavaScript in your application, add the following gem to your Gemfile when upgrading to Workarea 3.7:

```ruby
gem 'workarea-legacy_javascript'
```

This will load in all of the JS files that were taken out of Workarea with the move to Stimulus, allowing your site to work as normal when upgrading. It also configures the application to not load the Stimulus JS in order to prevent conflicts. Over time, you may choose to rewrite your own JS code into Stimulus controllers. If you do this, you can safely remove this gem from your Gemfile. The legacy JS code will be around for quite some time, as we have no plans to drop support for it, meaning you can do this work at a later date or not at all if it's too big of a job. Any new plugins or features developed post 3.7 will **not** include backports to the legacy JavaScript, and we will not accept pull requests on the gem to make it happen, so if you want to stay on the bleeding edge it's probably best to upgrade your JS to Stimulus.

You'll also want to run the `webpacker:install:workarea` Rake task after upgrading, to install dependencies over Yarn:

```
rails webpacker:install:workarea
```

Workarea now publishes an NPM package containing all of the JavaScript code for the platform, which is useful because it also specifies which packages the platform depends on.
