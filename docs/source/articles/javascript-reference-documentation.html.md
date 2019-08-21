---
title: JavaScript Reference Documentation
created_at: 2018/07/31
excerpt: Workarea JavaScripts are documented with JSDoc comments. You can generate HTML documentation (among other formats) using a variety of tools designed to parse JSDoc comments, including the jsdoc tool itself.
---

# JavaScript Reference Documentation

Workarea JavaScripts are documented with [JSDoc](http://usejsdoc.org/) comments. You can generate HTML documentation (among other formats) using a variety of tools designed to parse JSDoc comments, including the `jsdoc` tool itself.

## Installing JSDoc

Install `jsdoc` or a similar tool using [npm](https://www.npmjs.com/).

```
npm install -g jsdoc
```

## Generating Documentation for Installed Gems

Create a directory for the generated documentation within your application.

```
cd path/to/your_app
mkdir docs
```

The following commands will generate the JavaScript reference documentation for workarea-core, workarea-admin, and workarea-storefront and place them within subdirectories of `/docs`, which was created above.

```
cd path/to/your_app
bundle
jsdoc `bundle show workarea-core` -r -d ./docs/workarea-core-javascript-reference
jsdoc `bundle show workarea-admin` -r -d ./docs/workarea-admin-javascript-reference
jsdoc `bundle show workarea-storefront` -r -d ./docs/workarea-store-front-javascript-reference
```

## Viewing Documentation

The commands above generate static HTML files. Open `index.html` to browser the documentation.

```
open docs/workarea-core-javascript-reference/index.html
```

**Note:** Avoid using undocumented Workarea functions and properties. They should be considered private and unstable.

Use similar commands to generate documentation for any Workarea plugins or additional gems.

**Note:** You may want to commit the documentation files into your application's code repository to save your teammates the trouble of generating their own documentation. Conversly, you may want to instruct your version control system to ignore these directories to force developers to generate fresh documentation each time.


