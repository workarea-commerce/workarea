---
title: JavaScript Overview
created_at: 2018/07/31
excerpt: "An introduction to Workarea's JavaScript system, as well as the myriad of ways to get JavaScript into your Workarea application."
---

# JavaScript Overview

This is an introduction to Workarea's JavaScript system, as well as the myriad of ways to get JavaScript into your Workarea application.

## The JavaScript Universe According to Workarea

Workarea generally uses JavaScript as a way to bring some more interactivity to existing server-rendered HTML. For this reason, Workarea's own JavaScript code is organized using the [Stimulus](https://stimulusjs.com) JavaScript framework, with a few extensions providing each engine's controller codebase into your host app in a similar fashion as Rails engines.

In addition to these externalities, Workarea provides a means of compiling data-driven HTML templates on the client side using [EJS](/articles/javascript-templates.html), [application configuration](/articles/configuration.html) as well as the ability to [access Rails routes](/articles/access-routes-in-javascript.html) and [i18n translations](/articles/access-i18n-in-javascript.html) in your JavaSCript code.

In addition to Stimulus, Workarea depends on a number of JavaScript packages to speed up your development process. These dependencies are provided to your Workarea application as [NPM](http://npmjs.com) packages, using the [Yarn](http://yarnpkg.com) package manager, and are available both in Sprockets (for CSS) and Webpacker (for JS). One of these dependencies, Feature.js, behaves a bit differently than the others, and Workarea also has a feature test helper file that interacts with Feature.js. Those topics are covered in the cleverly named [Feature.js & Feature Test Helper](/articles/featurejs-and-feature-spec-helper.html) guide.

## Including Custom JavaScript

There are several ways to get JavaScript into your Workarea application, such as:

- [Adding JavaScript through a view](/articles/add-javascript-through-a-view.html)
- [Adding JavaScript through the Admin UI](/articles/add-javascript-through-the-admin-ui.html)
- [Adding or Decorating JavaScript Controllers](/articles/add-or-decorate-javascript-controllers.html)

Plugins can add their own assets to your app as well, so check out [Appending](/articles/appending.html) to take control of that process.

## Some Last Words on JavaScript

Lastly, [JavaScript reference documentation](/articles/javascript-reference-documentation.html) is available, which covers each of the public functions and their signatures.

If you'd care to [contribute](/articles/contribute-code.html) code back to the platform, or if you obsess over code style, check out the Workarea [JavaScript coding standards](/articles/javascript-coding-standards.html).
