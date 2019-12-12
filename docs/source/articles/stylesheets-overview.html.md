---
title: Stylesheets Overview
created_at: 2018/07/31
excerpt: A new Workarea application includes no stylesheets of its own. Create one to see for yourself :) However, the Workarea platform adds an Admin and a Storefront to the application, and each of those includes its own stylesheets to bootstrap the applicat
---

# Stylesheets Overview

A new Workarea application includes no stylesheets of its own. [Create one to see for yourself](/articles/create-a-new-app.html) :) However, the Workarea platform adds an Admin and a Storefront to the application, and each of those includes its own stylesheets to bootstrap the application.

This guide provides an overview of (1) how to get stylesheets on the page and (2) understanding stylesheets provided by Workarea.

## Getting Stylesheets on the Page

Looking at the Storefront of a vanilla Workarea app (no customizations or plugins) in production, the home page includes one `style` element and one stylesheet `link` tag.

The `style` tag is included in all Workarea layout files to provide parity with the `<meta name=viewport>` element. Some devices support the HTML element, while others require the viewport rules to be specified in CSS. Workarea includes the styles within the layout to keep this logic in one place.

workarea-storefront/app/views/layouts/workarea/storefront/application.html.haml:

```
<!-- ... -->

  <head>
    <!-- ... -->

    <meta name='viewport' content='width=device-width, user-scalable=no'>

    <!-- ... -->

    <style>
      @-ms-viewport { width: device-width; }
      @viewport { width: device-width; }
    </style>

    <!-- ... -->
  </head>

<!-- ... -->
```

A single stylesheet is also reference in the document `head`. It looks something like this.

```
<link rel="stylesheet" media="all" href="https://vanilla-app-production-workarea.cdn-ssl.com/assets/workarea/storefront/application-4db34e2c17577a8bd410f364367a61481494c5fd1bb25217b05b14a426b54abb.css">
```

The file name of the stylesheet above is:

`application-4db34e2c17577a8bd410f364367a61481494c5fd1bb25217b05b14a426b54abb.css`

**This is the application stylesheet manifests, the primary mechanism for adding and removing stylesheets in your app**. Unless you have a good reason to do otherwise, **[Add and remove stylesheets using a manifest](/articles/add-stylesheets-through-a-manifest.html)**. Not familiar with asset manifests? [I've got you covered](/articles/rails-asset-manifests.html).

If you do have a good reason to do otherwise, you can also [add CSS through the Admin UI](/articles/add-css-through-the-admin-ui.html).

Plugins can add their own assets to your app as well, so check out [Appending](/articles/appending.html) to take control of that process.

## Stylesheets According to Workarea

To understand the structure of the stylesheets provided by Workarea you should familiarize yourself with the [CSS Architectural overview](/articles/css-architectural-overview.html) documentation.

Workarea also has a feature test helper file that is included in the test environment only. This file is covered in the [Feature Test Helper Stylesheet](/articles/feature-spec-helper-stylesheet.html) guide.

## Some Last Words on Stylesheets

Lastly, UI components are documented and tested using [style guides](/articles/style-guides.html) within each application.

If you'd care to [contribute](/articles/contribute-code.html) code back to the platform, or if you obsess over code style, check out the Workarea [stylesheet coding standards](/articles/stylesheet-coding-standards.html).
