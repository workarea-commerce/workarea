---
title: JavaScript Overview
created_at: 2018/07/31
excerpt: "An introduction to Workarea's JavaScript system, as well as the myriad of ways to get JavaScript into your Workarea application."
---

# JavaScript Overview

This is an introduction to Workarea's JavaScript system, as well as the myriad of ways to get JavaScript into your Workarea application.

## The JavaScript Universe According to Workarea

Workarea generally uses JavaScript as a way to bring some more interactivity to existing server-rendered HTML. For this reason, Workarea's own JavaScript code is organized using the [Stimulus](https://stimulusjs.com) JavaScript framework, with a few extensions providing each engine's controller codebase into your host app in a similar fashion as Rails engines. Speaking of controllers, those are how most of the Workarea JS is organized, so [read up on controllers](https://stimulusjs.org/reference/controllers) in the Stimulus docs for more information. As a result of using Stimulus, Workarea's JavaScript is loaded using [Webpacker](https://github.com/rails/webpacker) and is compiled from the latest ECMAScript proposals and standards to a dialect of JavaScript which can be understood by any supported browser.

In addition to the aformentioned extraditionary code from a traditional Stimulus application, Workarea provides a means of compiling data-driven HTML templates on the client side using [EJS](/articles/javascript-templates.html), reading [application configuration](/articles/configuration.html), as well as the ability to [access Rails routes](/articles/access-routes-in-javascript.html) and i18n translations in your JavaScript code.

Workarea also depends on a number of JavaScript packages to speed up your development process, such as [js-cookie](https://github.com/js-cookie/js-cookie) and [change-case](https://github.com/blakeembrey/change-case). These dependencies are provided to your Workarea application as [NPM](http://npmjs.com) packages, using the [Yarn](http://yarnpkg.com) package manager, and are available both in Sprockets (for CSS) and Webpacker (for JS). One of these dependencies, Feature.js, behaves a bit differently than the others, and Workarea also has a feature test helper file that interacts with Feature.js. Those topics are covered in the cleverly named [Feature.js & Feature Test Helper](/articles/featurejs-and-feature-spec-helper.html) guide.

## Including Custom JavaScript

There are several ways to get JavaScript into your Workarea application, such as:

- [Adding JavaScript through a view](/articles/add-javascript-through-a-view.html)
- [Adding JavaScript through the Admin UI](/articles/add-javascript-through-the-admin-ui.html)
- [Adding or Decorating JavaScript Controllers](/articles/add-or-decorate-javascript-controllers.html)

Plugins can add their own assets to your app as well, so check out [Appending](/articles/appending.html) to take control of that process.

## Your JavaScript Application

Workarea generates two JS application files, **app/javascript/admin/application.js** and **app/javascript/storefront/application.js**. These files create a new instance of `Workarea.Application`, and `use()` a specific engine from the base platform, either `Admin` or `Storefront` respectively. The application file is where you can set configuration and import plugins for use in either admin or storefront (or both). To add a plugin, `import` it and then `use()` it in your app like so:

```javascript
// app/javascript/storefront/application.js

import { Application, Storefront } from "workarea"
import SearchAutocomplete from "@workarea/search-autocomplete"

const App = new Application("storefront")

App.use(Storefront)
App.use(SearchAutocomplete)

export default App
```


## Reading I18n Translations in JavaScript

To read i18n in your JS code, import the `I18n` module and use the `.t()` method like so:

```javascript
import I18n from "workarea/i18n"

I18n.t("workarea.admin.title")
```

## Configuration in JavaScript

You can apply configuration settings by running the `configure()` method of your JS application:

```javascript
// app/javascript/storefront/application.js

import { Application, Storefront } from "workarea"

const App = new Application("storefront")

App.use(Storefront)

App.configure(config => {
  config.foo = 'bar'
})

export default App
```

## Some Last Words on JavaScript

Lastly, [JavaScript reference documentation](/articles/javascript-reference-documentation.html) is available, which covers each of the public functions and their signatures.

If you'd care to [contribute](/articles/contribute-code.html) code back to the platform, or if you obsess over code style, check out the Workarea [JavaScript coding standards](/articles/javascript-coding-standards.html).
