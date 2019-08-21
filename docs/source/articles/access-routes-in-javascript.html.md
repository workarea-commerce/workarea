---
title: Access Routes in JavaScript
created_at: 2018/09/17
excerpt: Who likes hard coding paths into an application only to see them change? Not me. That's why Rails provides routing helpers for use in Rails views and controllers. To get access to these in JavaScript templates and modules, Workarea provides WORKAREA.ro
---

# Access Routes in JavaScript

Who likes hard coding paths into an application only to see them change? Not me. That's why Rails provides routing helpers for use in Rails views and controllers. To get access to these in JavaScript templates and modules, Workarea provides `WORKAREA.routes.admin` and `WORKAREA.routes.storefront`.

Each property on these objects is a function that returns the corresponding path string.

```
WORKAREA.routes.storefront.loginPath() // returns "/login"
```

## How it Works

The functionality is provided by [Js-routes](http://railsware.github.io/js-routes/) and is included in the Admin and Storefront JavaScript manifests.

Admin:

```
workarea/core/routes
workarea/admin/routes
```

Storefront:

```
workarea/core/routes
workarea/storefront/routes
```

