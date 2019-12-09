---
title: JavaScript Overview
created_at: 2018/07/31
excerpt: A new Workarea application includes no JavaScript of its own. Create one to see for yourself. However, the Workarea platform adds an Admin and a Storefront to the application, and each of those includes its own JavaScript files that are fully custom
---

# JavaScript Overview

A new Workarea application includes no JavaScript of its own. [Create one to see for yourself](/articles/create-a-new-app.html). However, the Workarea platform adds an Admin and a Storefront to the application, and each of those includes its own JavaScript files that are fully customizable.

This guide provides an overview of (1) how to get JavaScript on the page and (2) understanding JavaScript provided by Workarea.

## Getting JavaScript on the Page

Looking at the Storefront of a vanilla Workarea app (no customizations or plugins) in production, there are exactly 3 `script` elements, 2 in the `head` and 1 in the `body`.

The first in the head looks something like this:

```
<script type="text/javascript">window.NREUM /*...*/</script>
```

You won't see this code anywhere in the application. It's injected into the page by the New Relic APM agent to capture and report analytics back to [New Relic](http://newrelic.com/). This code is added at the middleware level and may vary based on your hosting arrangement.

The next `script` tag in the head looks something like this:

```
<script src="https://vanilla-app-production-workarea.cdn-ssl.com/assets/workarea/storefront/head-041c56bdb2104549c9bf5779d5de6892ca91d665a94417092f8233ea460689da.js"></script>
```

And the one in the body looks something like this:

```
<script src="https://vanilla-app-production-workarea.cdn-ssl.com/assets/workarea/storefront/application-2c3748f10d7452eaa5d2572fabc099650b49f8a372d0cc69c414aaeaf16ae62a.js"></script>
```

If you take the time to scroll horizontally (or look below), you'll see the file names are:

`head-041c56bdb2104549c9bf5779d5de6892ca91d665a94417092f8233ea460689da.js`

And:

`application-2c3748f10d7452eaa5d2572fabc099650b49f8a372d0cc69c414aaeaf16ae62a.js`

**These are the head and application JavaScript manifests, the primary mechanisms for adding and removing JavaScript files in your app**. Unless you have a good reason to do otherwise, **[Add and remove JavaScripts using a manifest](/articles/add-javascript-through-a-manifest.html)**. Not familiar with asset manifests? [I've got you covered](/articles/add-javascript-through-a-manifest.html).

So what if you do have a good reason to do otherwise? Then you can [add JavaScript through a view](/articles/add-javascript-through-a-view.html) or [add JavaScript through the Admin UI](/articles/add-javascript-through-the-admin-ui.html).

Plugins can add their own assets to your app as well, so check out [Appending](/articles/appending.html) to take control of that process.

## The JavaScript Universe According to Workarea

To understand the JavaScript provided by Workarea you should familiarize yourself with [Workarea modules](/articles/javascript-modules.html) and [JST/EJS templates](/articles/javascript-templates.html).

Also good to know are how to [access Rails routes in JavaScript](/articles/access-routes-in-javascript.html) and how to [configure JavaScript](/articles/configuration.html).

Regarding JavaScript dependencies, Feature.js behaves a bit differently than the others, and Workarea also has a feature test helper file that interacts with Feature.js. Those topics are covered in the cleverly named [Feature.js & Feature Test Helper](/articles/featurejs-and-feature-spec-helper.html) guide.

## Some Last Words on JavaScript

Lastly, [JavaScript reference documentation](/articles/javascript-reference-documentation.html) is available, which covers each of the public functions and their signatures.

If you'd care to [contribute](/articles/contribute-code.html) code back to the platform, or if you obsess over code style, check out the Workarea [JavaScript coding standards](/articles/javascript-coding-standards.html).
