---
title: JavaScript Reference Documentation
created_at: 2018/07/31
excerpt: Workarea JavaScripts are documented with JSDoc comments. You can generate HTML documentation (among other formats) using a variety of tools designed to parse JSDoc comments, including the jsdoc tool itself.
---

# JavaScript Reference Documentation

Workarea's JavaScript code is documented with [ESDoc](http://esdoc.org/) comments. You can generate HTML documentation (among other formats) using a variety of tools designed to parse JSDoc comments, including the `esdoc` tool itself.

## Installing JSDoc

Install `esdoc` or a similar tool:

```
yarn add esdoc
```

## Generating Documentation for Installed Gems

Create a directory for the generated documentation within your application.

```
cd path/to/your_app
mkdir -p docs/js
```

The following commands will generate the JavaScript reference documentation for workarea-core, workarea-admin, and workarea-storefront and place them within subdirectories of `/docs`, which was created above.

```bash
cd path/to/your_app
bundle
esdoc `bundle show workarea-core` -r -d ./docs/js/workarea
esdoc `bundle show workarea-admin` -r -d ./docs/js/workarea/admin
esdoc `bundle show workarea-storefront` -r -d ./docs/js/workarea/storefront
```

## Viewing Documentation

The commands above generate static HTML files. Open `index.html` to browser the documentation.

```
open docs/js/workarea/index.html
```

**Note:** Avoid using undocumented Workarea functions and properties. They should be considered private and unstable.

Use similar commands to generate documentation for any Workarea plugins or additional gems.
